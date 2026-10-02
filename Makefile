.PHONY: backend-build backend-test emulators deploy

backend-build:
	cd functions && npm run build

backend-test:
	cd functions && npm test

emulators:
	firebase emulators:start

deploy:
	firebase deploy --only firestore:rules,firestore:indexes,functions
