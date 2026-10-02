import {HttpsError} from "firebase-functions/v2/https";
import type {LatLng, RouteSummary} from "./types.js";

type RoutesApiRoute = {
  duration?: string;
  distanceMeters?: number;
  polyline?: {encodedPolyline?: string};
  localizedValues?: {
    duration?: {text?: string};
    distance?: {text?: string};
  };
  legs?: Array<{
    steps?: Array<{
      travelMode?: string;
      transitDetails?: {
        stopDetails?: {
          departureStop?: {name?: string};
          arrivalStop?: {name?: string};
        };
        transitLine?: {
          name?: string;
          nameShort?: string;
          vehicle?: {name?: {text?: string}};
        };
        headsign?: string;
        stopCount?: number;
      };
    }>;
  }>;
};

function secondsFromDuration(duration: string | undefined): number {
  if (!duration) return 0;
  return Number(duration.replace(/s$/, "")) || 0;
}

function summarizeTransitSteps(route: RoutesApiRoute): string[] {
  const steps = route.legs?.flatMap((leg) => leg.steps ?? []) ?? [];
  return steps
    .filter((step) => step.travelMode === "TRANSIT" && step.transitDetails)
    .map((step) => {
      const details = step.transitDetails!;
      const line = details.transitLine?.nameShort || details.transitLine?.name || "Transit";
      const from = details.stopDetails?.departureStop?.name || "departure stop";
      const to = details.stopDetails?.arrivalStop?.name || "arrival stop";
      const headsign = details.headsign ? ` toward ${details.headsign}` : "";
      return `${line}${headsign}: ${from} to ${to}`;
    });
}

export async function computeTransitRoutes(args: {
  apiKey: string;
  origin: LatLng;
  destination: LatLng;
  arrivalTimeISO?: string;
  preference: "BALANCED" | "LESS_WALKING" | "FEWER_TRANSFERS";
}): Promise<RouteSummary[]> {
  const body: Record<string, unknown> = {
    origin: {location: {latLng: args.origin}},
    destination: {location: {latLng: args.destination}},
    travelMode: "TRANSIT",
    computeAlternativeRoutes: true,
    languageCode: "en-US",
    units: "IMPERIAL",
  };

  if (args.arrivalTimeISO) body.arrivalTime = args.arrivalTimeISO;
  if (args.preference !== "BALANCED") {
    body.transitPreferences = {routingPreference: args.preference};
  }

  const response = await fetch("https://routes.googleapis.com/directions/v2:computeRoutes", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-Goog-Api-Key": args.apiKey,
      "X-Goog-FieldMask": [
        "routes.duration",
        "routes.distanceMeters",
        "routes.polyline.encodedPolyline",
        "routes.localizedValues.duration",
        "routes.localizedValues.distance",
        "routes.legs.steps.travelMode",
        "routes.legs.steps.transitDetails",
      ].join(","),
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    console.error("Routes API error", response.status, errorBody);
    throw new HttpsError("unavailable", "Transit routing is temporarily unavailable.");
  }

  const payload = (await response.json()) as {routes?: RoutesApiRoute[]};
  return (payload.routes ?? []).slice(0, 4).map((route, index) => ({
    id: `route-${index + 1}`,
    durationText: route.localizedValues?.duration?.text ?? route.duration ?? "Unknown duration",
    distanceText: route.localizedValues?.distance?.text ?? `${route.distanceMeters ?? 0} m`,
    durationSeconds: secondsFromDuration(route.duration),
    distanceMeters: route.distanceMeters ?? 0,
    encodedPolyline: route.polyline?.encodedPolyline,
    transitSteps: summarizeTransitSteps(route),
  }));
}
