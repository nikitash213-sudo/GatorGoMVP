import {HttpsError} from "firebase-functions/v2/https";
import {z} from "zod";

export const latLngSchema = z.object({
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
});

export const askNavigatorSchema = z.object({
  query: z.string().trim().min(3).max(500),
});

export const planTripSchema = z.object({
  origin: latLngSchema,
  destination: latLngSchema,
  destinationLabel: z.string().trim().min(1).max(120),
  arrivalTimeISO: z.string().datetime().optional(),
  preference: z.enum(["BALANCED", "LESS_WALKING", "FEWER_TRANSFERS"]).default("BALANCED"),
  budgetNote: z.string().trim().max(120).optional(),
  accessibilityNote: z.string().trim().max(200).optional(),
});

export const claimLandmarkSchema = z.object({
  landmarkId: z.string().trim().min(1).max(120),
  location: latLngSchema,
  accuracyMeters: z.number().positive().max(500),
});

export function parseOrThrow<T>(schema: z.ZodType<T>, value: unknown): T {
  const result = schema.safeParse(value);
  if (!result.success) {
    throw new HttpsError("invalid-argument", "Invalid request.", {
      issues: result.error.issues.map((issue) => ({
        path: issue.path.join("."),
        message: issue.message,
      })),
    });
  }
  return result.data;
}

export function requireAuth(uid: string | undefined): string {
  if (!uid) {
    throw new HttpsError("unauthenticated", "Authentication is required.");
  }
  return uid;
}
