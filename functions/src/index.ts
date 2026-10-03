import {initializeApp} from "firebase-admin/app";
import {DocumentData, FieldValue, Timestamp, getFirestore} from "firebase-admin/firestore";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret, defineString} from "firebase-functions/params";
import {answerResourceQuestion, explainTrip} from "./ai.js";
import {distanceMeters} from "./geo.js";
import {computeTransitRoutes} from "./routes.js";
import type {LandmarkRecord, ResourceRecord} from "./types.js";
import {
  askNavigatorSchema,
  claimLandmarkSchema,
  parseOrThrow,
  planTripSchema,
  requireAuth,
} from "./validation.js";

initializeApp();
const db = getFirestore();

const geminiApiKey = defineSecret("GEMINI_API_KEY");
const routesApiKey = defineSecret("ROUTES_API_KEY");
const geminiModel = defineString("GEMINI_MODEL", {default: "gemini-3.8-flash"});

const callableOptions = {
  region: "us-west1",
  enforceAppCheck: true,
  timeoutSeconds: 30,
  maxInstances: 20,
} as const;

function isoFromFirestore(value: unknown): string {
  if (value instanceof Timestamp) return value.toDate().toISOString();
  if (typeof value === "string") return value;
  return new Date(0).toISOString();
}

function resourceFromDoc(id: string, data: DocumentData): ResourceRecord {
  const location = data.location && typeof data.location.latitude === "number"
    ? {latitude: data.location.latitude, longitude: data.location.longitude}
    : undefined;

  return {
    id,
    title: String(data.title ?? "Untitled"),
    category: String(data.category ?? "other"),
    summary: String(data.summary ?? ""),
    eligibility: String(data.eligibility ?? "Verify at source"),
    costLabel: String(data.costLabel ?? "See source"),
    sourceURL: String(data.sourceURL ?? ""),
    sourceName: String(data.sourceName ?? "Source"),
    updatedAtISO: isoFromFirestore(data.updatedAt),
    expiresAtISO: data.expiresAt ? isoFromFirestore(data.expiresAt) : undefined,
    location,
    isActive: data.isActive === true,
    isDemo: data.isDemo === true,
  };
}

function geminiStatusCode(error: unknown): number | undefined {
  if (typeof error !== "object" || error === null || !("status" in error)) {
    return undefined;
  }
  return typeof error.status === "number" ? error.status : undefined;
}

function geminiUnavailable(error: unknown, model: string): HttpsError {
  const statusCode = geminiStatusCode(error);
  console.error("Gemini API request failed", {
    model,
    errorType: error instanceof Error ? error.name : "UnknownError",
    statusCode,
  });

  const message = statusCode === 503
    ? "The Gemini service is temporarily unavailable. Please try again shortly."
    : statusCode === 404
      ? `The configured Gemini model (${model}) is unavailable. Choose a model enabled for this API key.`
      : statusCode === 400 || statusCode === 401 || statusCode === 403
        ? "Gemini rejected the request. Check that the API key is valid and Gemini API access is enabled."
        : "The AI service could not generate a response. Please try again later.";

  return new HttpsError(
    "unavailable",
    message,
  );
}

async function activeResources(limit = 30): Promise<ResourceRecord[]> {
  const snapshot = await db.collection("resources")
    .where("isActive", "==", true)
    .limit(limit)
    .get();
  return snapshot.docs.map((doc) => resourceFromDoc(doc.id, doc.data()));
}

export const askNavigator = onCall(
  {...callableOptions, secrets: [geminiApiKey]},
  async (request) => {
    requireAuth(request.auth?.uid);
    const input = parseOrThrow(askNavigatorSchema, request.data);
    const resources = await activeResources();

    if (resources.length === 0) {
      throw new HttpsError("failed-precondition", "No verified resource records are available.");
    }

    let result: Awaited<ReturnType<typeof answerResourceQuestion>>;
    try {
      result = await answerResourceQuestion({
        apiKey: geminiApiKey.value(),
        model: geminiModel.value(),
        query: input.query,
        resources,
      });
    } catch (error) {
      throw geminiUnavailable(error, geminiModel.value());
    }

    const selected = result.resourceIds
      .map((id) => resources.find((resource) => resource.id === id))
      .filter((resource): resource is ResourceRecord => Boolean(resource));

    return {
      answer: result.answer,
      caveats: result.caveats,
      resources: selected,
      generatedAtISO: new Date().toISOString(),
      model: geminiModel.value(),
    };
  },
);

export const planTrip = onCall(
  {...callableOptions, secrets: [geminiApiKey, routesApiKey]},
  async (request) => {
    requireAuth(request.auth?.uid);
    const input = parseOrThrow(planTripSchema, request.data);

    const routes = await computeTransitRoutes({
      apiKey: routesApiKey.value(),
      origin: input.origin,
      destination: input.destination,
      arrivalTimeISO: input.arrivalTimeISO,
      preference: input.preference,
    });

    if (routes.length === 0) {
      throw new HttpsError("not-found", "No transit route was returned for this trip.");
    }

    const resources = (await activeResources()).filter((resource) => {
      if (!resource.location) return false;
      return distanceMeters(resource.location, input.destination) <= 2_000;
    }).slice(0, 8);

    let explanation: Awaited<ReturnType<typeof explainTrip>>;
    try {
      explanation = await explainTrip({
        apiKey: geminiApiKey.value(),
        model: geminiModel.value(),
        destinationLabel: input.destinationLabel,
        budgetNote: input.budgetNote,
        accessibilityNote: input.accessibilityNote,
        routes,
        resources,
      });
    } catch (error) {
      throw geminiUnavailable(error, geminiModel.value());
    }

    const selectedResources = explanation.resourceIds
      .map((id) => resources.find((resource) => resource.id === id))
      .filter((resource): resource is ResourceRecord => Boolean(resource));

    return {
      routes,
      explanation: explanation.summary,
      recommendedRouteId: explanation.recommendedRouteId,
      caveats: explanation.caveats,
      resources: selectedResources,
      generatedAtISO: new Date().toISOString(),
      model: geminiModel.value(),
    };
  },
);

export const claimLandmark = onCall(
  callableOptions,
  async (request) => {
    const uid = requireAuth(request.auth?.uid);
    const input = parseOrThrow(claimLandmarkSchema, request.data);

    if (input.accuracyMeters > 100) {
      throw new HttpsError("failed-precondition", "Location accuracy is too low. Move outdoors and try again.");
    }

    const landmarkRef = db.collection("landmarks").doc(input.landmarkId);
    const landmarkSnapshot = await landmarkRef.get();
    if (!landmarkSnapshot.exists) {
      throw new HttpsError("not-found", "Landmark not found.");
    }

    const data = landmarkSnapshot.data()!;
    const landmark: LandmarkRecord = {
      id: landmarkSnapshot.id,
      name: String(data.name ?? "Landmark"),
      category: String(data.category ?? "other"),
      description: String(data.description ?? ""),
      location: {
        latitude: Number(data.location?.latitude),
        longitude: Number(data.location?.longitude),
      },
      claimRadiusMeters: Number(data.claimRadiusMeters ?? 100),
      isActive: data.isActive === true,
    };

    if (!landmark.isActive || !Number.isFinite(landmark.location.latitude) || !Number.isFinite(landmark.location.longitude)) {
      throw new HttpsError("failed-precondition", "This landmark cannot be claimed right now.");
    }

    const distance = distanceMeters(input.location, landmark.location);
    if (distance > landmark.claimRadiusMeters) {
      throw new HttpsError("failed-precondition", `You are about ${Math.round(distance)} m from this landmark.`);
    }

    const claimRef = db.collection("users").doc(uid).collection("claims").doc(landmark.id);
    await claimRef.set({
      landmarkId: landmark.id,
      landmarkName: landmark.name,
      claimedAt: FieldValue.serverTimestamp(),
      verificationMethod: "server-distance",
      distanceMeters: Math.round(distance),
      accuracyMeters: Math.round(input.accuracyMeters),
    }, {merge: true});

    return {
      landmarkId: landmark.id,
      landmarkName: landmark.name,
      distanceMeters: Math.round(distance),
      claimed: true,
    };
  },
);
