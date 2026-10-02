# MVP acceptance criteria

## P0 — must work in the demo

- App launches and obtains a Firebase Auth identity without mandatory registration.
- Resources screen loads active Firestore records and exposes source/freshness.
- Ask GatorGo returns only records that existed in the server-retrieved candidate set.
- AI parse/validation failure produces a deterministic fallback rather than ungrounded content.
- Trip Planner obtains user location only after the user initiates planning.
- Trip Planner returns at least one Routes API transit option for a supported origin/destination.
- Transit response includes duration and at least route/step detail available from the API.
- Explore screen displays at least five landmarks.
- Claim requires user action, location permission, acceptable GPS accuracy, and server-side distance verification.
- Claim persistence does not include the submitted raw latitude/longitude.
- Firestore client writes to resource/landmark/claim records are denied.
- Gemini and Routes API keys do not exist in the iOS bundle or repository.

## P1 — strongly recommended before judging

- Replace demo resources with 15-30 verified SFSU/student records.
- Verify campus landmark coordinates and tune claim radius using on-device tests.
- Register App Check debug tokens for simulator demos and App Attest for physical devices.
- Test location denied, poor accuracy, no transit route, API failure, malformed AI output, and stale data.
- Capture screenshots/video of the grounding/freshness UI for the submission.

## P2 — after hackathon

- Account linking / Sign in with Apple.
- Admin resource-maintenance UI with custom-claim authorization.
- Full place autocomplete/geocoding and richer route selection.
- Production analytics, budget alerts, monitoring, and abuse controls.
