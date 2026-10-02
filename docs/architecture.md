# Architecture decisions

## Client

SwiftUI owns presentation and view state. It reads the public-to-authenticated-user catalog directly from Firestore and invokes sensitive or authoritative operations through typed Firebase callable functions.

Google Maps SDK is isolated behind `GoogleMapView`, a `UIViewRepresentable`, because the SDK's primary map view is UIKit-based. Keeping it behind an adapter avoids leaking SDK-specific types through feature code.

## Authentication

Anonymous Firebase Authentication is used for the MVP because it creates a per-user security boundary without forcing account creation. A later Sign in with Apple flow should link the anonymous user so collections survive the upgrade.

## Backend

Cloud Functions for Firebase v2 run in `us-west1`. Keep Firestore in the same region for lower latency and reduced cross-region cost.

Only three callables are exposed:

- `askNavigator`: resource retrieval + grounded AI synthesis.
- `planTrip`: Google Routes transit request + nearby resource retrieval + grounded AI explanation.
- `claimLandmark`: server-side distance verification + minimal claim record.

## AI grounding contract

The model never queries Firestore itself and never receives unrestricted app state. The server retrieves candidate records, serializes only required fields, asks for IDs from that candidate set, validates the model output, and discards IDs that were not retrieved.

If model output is malformed, a deterministic fallback is returned.

## Location privacy

The iOS client requests location only for explicit trip planning or landmark claims. `claimLandmark` computes distance on the server and stores the landmark claim, rounded verification distance, and reported accuracy. It does not persist the submitted latitude/longitude.
