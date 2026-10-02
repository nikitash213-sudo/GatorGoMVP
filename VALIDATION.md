# Validation status

Validated in the generation environment:

- Swift source files pass `swiftc -parse` syntax validation.
- TypeScript source files pass TypeScript `transpileModule` syntax validation.
- `project.yml` parses as valid YAML.
- `Info.plist` and app entitlements parse as valid XML.
- Firebase, Firestore index, package, and TypeScript configuration files parse as valid JSON.

Not fully executed here:

- `npm install` could not complete in the generation environment, so package-resolved TypeScript type checking and tests must be run locally with `npm install && npm test`.
- The iOS app cannot be linked/built here because Xcode, iOS SDKs, Firebase Apple packages, and Google Maps iOS packages are not available in this environment.
- Live Firebase, Routes API, Gemini API, App Check, and GPS flows require your project credentials/configuration and should be tested on your simulator/device.

Before demo day, run the P0/P1 checks in `docs/acceptance-criteria.md` on the exact build you will present.
