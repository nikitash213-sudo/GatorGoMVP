# GatorGo MVP

A demo-ready SFSU transit and student-resource navigator built with SwiftUI, Firebase/Google Cloud, Firestore, Google Maps + Routes API, Gemini API, and Firebase Authentication.

This repository implements the smallest credible version of the product design:

- Plan a transit trip from the student's current location to a curated campus landmark.
- Browse a verified-resource-shaped Firestore catalog with source and freshness metadata.
- Ask a natural-language question and receive an AI answer grounded only in retrieved Firestore records.
- Explore campus landmarks on a map and claim a landmark using user-initiated proximity verification.
- Inspect caveats and source/freshness information before acting.

> The included seed records and landmark coordinates are **demo data**. Replace them with verified SFSU records before public use.

## Architecture

```text
SwiftUI iOS app
  |-- Firebase Auth (anonymous for MVP)
  |-- Firestore reads (resources, landmarks, claims)
  |-- Firebase App Check (Debug on simulator, App Attest on device)
  |-- Google Maps SDK for iOS
  |
  +-- HTTPS Callable Functions (Auth + App Check)
        |-- planTrip
        |     |-- Google Routes API (TRANSIT)
        |     |-- Firestore nearby resources
        |     +-- Gemini API / Gemma grounded explanation
        |
        |-- askNavigator
        |     |-- Firestore active resources
        |     +-- Gemini API / Gemma grounded answer
        |
        +-- claimLandmark
              |-- Firestore landmark
              |-- server-side distance check
              +-- stores claim only; no raw location history
```

## Why this shape

- **No Gemini or Routes API secrets in the iOS app.** Both keys are Cloud Secret Manager-backed function secrets.
- **AI is retrieval-grounded.** The model receives only current candidate records and its returned record IDs are validated against the retrieved set.
- **Deterministic fallback.** If AI output cannot be parsed/validated, the backend returns a safe non-AI fallback rather than invented data. Gemini API request failures are surfaced as callable errors instead of being misreported as validation failures.
- **Server-authoritative claims.** The client requests location only after a user action; the server checks distance and stores only the claim plus minimal verification metadata.
- **Firestore is deny-by-default for writes.** Catalog and claim writes are server-only.
- **App Check + Auth protect callable endpoints.** Anonymous auth keeps the demo low-friction while still providing a per-user identity boundary.

## Repository layout

```text
GatorGoMVP/
  functions/                 Firebase Functions v2 / TypeScript / Node 22
  ios/GatorGo/               SwiftUI iOS app scaffold (XcodeGen project)
  firestore.rules            Firestore authorization
  firestore.indexes.json     Firestore indexes
  firebase.json              Firebase deploy/emulator config
  docs/                      Architecture, schema, acceptance criteria
```

## Prerequisites

- Xcode 26.2+ recommended for the current Firebase Apple SDK line.
- iOS 17+ target.
- Node.js 22.
- Firebase CLI.
- A Firebase / Google Cloud project on the Blaze plan for Functions and external API calls.
- XcodeGen (`brew install xcodegen`) to generate the included project spec.

## 1. Create and configure the Firebase project

Create one Firebase project for the MVP and choose **us-west1** for Firestore so the included Functions region is co-located.

Enable:

1. Firebase Authentication -> **Anonymous** provider.
2. Cloud Firestore.
3. Cloud Functions.
4. Firebase App Check for the iOS app.
5. Google Maps SDK for iOS.
6. Google Routes API.

Register an iOS app using bundle ID:

```text
edu.sfsu.gatorgo
```

Download `GoogleService-Info.plist` into:

```text
ios/GatorGo/GatorGo/GoogleService-Info.plist
```

Do not commit that file.

## 2. Configure secrets

From the repository root:

```bash
firebase login
firebase use --add
firebase functions:secrets:set GEMINI_API_KEY
firebase functions:secrets:set ROUTES_API_KEY
```

`GEMINI_MODEL` defaults to:

```text
gemini-3.8-flash
```

Set `GEMINI_MODEL` to another available model in the Functions environment if needed.

For the iOS Maps key:

```bash
cp ios/GatorGo/Config/Secrets.xcconfig.example ios/GatorGo/Config/Secrets.xcconfig
```

Then replace the placeholder with a **Google Maps iOS key restricted to the iOS bundle ID and Maps SDK for iOS**. Client-side Maps keys are not true secrets, so API and application restrictions are essential.

## 3. Install and validate the backend

```bash
cd functions
npm install
npm run build
npm test
cd ..
```

Deploy rules, indexes, and Functions:

```bash
firebase deploy --only firestore:rules,firestore:indexes,functions
```

## 4. Seed demo data

The seed is intentionally marked `isDemo: true` and should not be treated as verified production information.

Authenticate Application Default Credentials, then seed:

```bash
gcloud auth application-default login
cd functions
npm run seed
cd ..
```

Before a public demo, replace seed records with 15-30 verified resources containing source, freshness, eligibility, cost, and expiration fields where applicable.

## 5. Generate and run the iOS app

```bash
cd ios/GatorGo
xcodegen generate
open GatorGo.xcodeproj
```

In Xcode:

1. Select your development team.
2. Confirm `GoogleService-Info.plist` is in the GatorGo target.
3. Confirm App Attest is enabled for the app identifier/capabilities.
4. Build on a simulator or physical device.

### Simulator App Check

The app uses Firebase's Debug App Check provider in the simulator. On first launch, copy the debug token from the Xcode console and register it under Firebase Console -> App Check -> your iOS app -> debug tokens. Callable Functions have App Check enforcement enabled in code.

### Physical-device App Check

The app uses App Attest on physical devices. Configure App Check in the Firebase console before enabling enforcement for Firestore.

## 6. Local emulators

Start Firebase emulators:

```bash
firebase emulators:start
```

In the Xcode scheme, add this environment variable:

```text
USE_FIREBASE_EMULATORS=1
```

The app will connect Auth, Firestore, and Functions to localhost in Debug builds.

Note: the `planTrip` and AI functions still call external Google APIs and therefore still need their secrets. For completely offline unit tests, test the pure validation and geometry functions separately.

## MVP demo flow

1. Launch: app silently creates an anonymous Firebase user.
2. Resources: show curated resource cards and open a card to show source/freshness.
3. Ask: enter “What is a low-cost student option near campus?” and show a grounded response referencing retrieved records.
4. Plan: select a curated landmark, grant location permission, and show Google Routes transit options plus a grounded explanation.
5. Explore: show five landmarks on the map; when physically near one, tap Claim and show it added to the collection.
6. Trust: show the source/freshness and demo-data warning.

## Production hardening after the hackathon

- Replace demo catalog entries with maintained official records and a freshness/expiration policy.
- Add admin tooling behind custom claims rather than permitting client writes to catalog collections.
- Add rate limits/quotas and monitoring dashboards around expensive Routes/Gemini calls.
- Add structured audit logging without logging raw user location or sensitive free-text constraints.
- Add Sign in with Apple only when persistent cross-device identity is actually needed; link the anonymous account rather than forcing sign-up before value.
- Add unit/UI tests for denied location, poor GPS accuracy, no route, stale resource, App Check failure, offline mode, and malformed AI output.
- Consider Remote Config for model choice and feature flags, while keeping secret values in Secret Manager.

## Current deliberate MVP limitations

- Destinations are curated landmark coordinates instead of free-text autocomplete/geocoding.
- Transit planning is route-centric, not a full real-time disruption system.
- Resource search is a simple client-side filter over a small curated dataset.
- Landmark proximity is useful for a hackathon demo but is not strong anti-spoofing security.
- Demo seed content is not a substitute for verified SFSU data ownership and maintenance.
