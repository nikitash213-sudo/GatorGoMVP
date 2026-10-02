import {applicationDefault, initializeApp} from "firebase-admin/app";
import {Timestamp, getFirestore} from "firebase-admin/firestore";

initializeApp({credential: applicationDefault()});
const db = getFirestore();

const now = Timestamp.now();

const resources = [
  {
    id: "demo-transit-benefit",
    title: "Demo: Student Transit Benefit",
    category: "transportation",
    summary: "Prototype record representing an SFSU student transit benefit. Replace with a verified campus record before release.",
    eligibility: "Demo only — verify official eligibility requirements.",
    costLabel: "Demo — verify at source",
    sourceURL: "https://www.sfsu.edu/",
    sourceName: "San Francisco State University",
    updatedAt: now,
    location: {latitude: 37.7219, longitude: -122.4782},
    isActive: true,
    isDemo: true,
  },
  {
    id: "demo-campus-food",
    title: "Demo: Low-Cost Campus Food Resource",
    category: "food",
    summary: "Prototype record for a low-cost or free food resource available to students.",
    eligibility: "Demo only — verify eligibility and hours.",
    costLabel: "Free or low cost — verify",
    sourceURL: "https://www.sfsu.edu/",
    sourceName: "San Francisco State University",
    updatedAt: now,
    location: {latitude: 37.7221, longitude: -122.4786},
    isActive: true,
    isDemo: true,
  },
  {
    id: "demo-library-support",
    title: "Demo: Library Student Support",
    category: "academic",
    summary: "Prototype record for library study, technology, or student support services.",
    eligibility: "Demo only — verify access requirements.",
    costLabel: "Student resource — verify",
    sourceURL: "https://www.sfsu.edu/",
    sourceName: "San Francisco State University",
    updatedAt: now,
    location: {latitude: 37.7214, longitude: -122.4788},
    isActive: true,
    isDemo: true,
  },
  {
    id: "demo-wellness",
    title: "Demo: Campus Wellness Opportunity",
    category: "wellness",
    summary: "Prototype record for a campus wellness facility or student program.",
    eligibility: "Demo only — verify membership, hours, and availability.",
    costLabel: "Student resource — verify",
    sourceURL: "https://www.sfsu.edu/",
    sourceName: "San Francisco State University",
    updatedAt: now,
    location: {latitude: 37.7236, longitude: -122.4812},
    isActive: true,
    isDemo: true,
  },
  {
    id: "demo-culture",
    title: "Demo: Arts & Culture Opportunity",
    category: "activities",
    summary: "Prototype record for an affordable arts, museum, or culture opportunity near campus.",
    eligibility: "Demo only — verify dates and student discount requirements.",
    costLabel: "Free or discounted — verify",
    sourceURL: "https://www.sfsu.edu/",
    sourceName: "San Francisco State University",
    updatedAt: now,
    location: {latitude: 37.7219, longitude: -122.4774},
    isActive: true,
    isDemo: true,
  },
];

const landmarks = [
  {id: "campus-center", name: "Campus Center", category: "campus", description: "Demo campus landmark.", location: {latitude: 37.7219, longitude: -122.4782}, claimRadiusMeters: 120, isActive: true},
  {id: "student-center", name: "Student Center", category: "campus", description: "Demo student-services landmark.", location: {latitude: 37.7221, longitude: -122.4786}, claimRadiusMeters: 120, isActive: true},
  {id: "library", name: "Library", category: "academic", description: "Demo library landmark.", location: {latitude: 37.7214, longitude: -122.4788}, claimRadiusMeters: 120, isActive: true},
  {id: "wellness-center", name: "Wellness Center", category: "wellness", description: "Demo wellness landmark.", location: {latitude: 37.7236, longitude: -122.4812}, claimRadiusMeters: 120, isActive: true},
  {id: "transit-edge", name: "Transit Connection", category: "transit", description: "Demo transit-oriented landmark.", location: {latitude: 37.7208, longitude: -122.4759}, claimRadiusMeters: 140, isActive: true},
];

for (const resource of resources) {
  const {id, ...data} = resource;
  await db.collection("resources").doc(id).set(data, {merge: true});
}

for (const landmark of landmarks) {
  const {id, ...data} = landmark;
  await db.collection("landmarks").doc(id).set(data, {merge: true});
}

console.log(`Seeded ${resources.length} demo resources and ${landmarks.length} demo landmarks.`);
