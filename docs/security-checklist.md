# Security and privacy checklist

- [ ] Firebase Auth enabled; no broad unauthenticated Firestore access.
- [ ] Firestore rules deployed from source control and tested with Emulator Suite.
- [ ] Firebase App Check registered for the iOS app.
- [ ] App Check enforcement enabled for Firestore after valid clients are deployed.
- [ ] Callable Functions use `enforceAppCheck: true`.
- [ ] `GEMINI_API_KEY` and `ROUTES_API_KEY` stored as function secrets.
- [ ] Maps iOS key restricted to bundle ID `edu.sfsu.gatorgo` and Maps SDK for iOS.
- [ ] Server Routes key restricted to Routes API.
- [ ] No raw location is written to claims or logs.
- [ ] Free-text constraints are not stored by default.
- [ ] Catalog writes use Admin SDK / controlled admin workflow only.
- [ ] Expired records are disabled or excluded before AI retrieval.
- [ ] API quotas/budget alerts configured before broader testing.
