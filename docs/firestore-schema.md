# Firestore schema

## `resources/{resourceId}`

```text
title: string
category: string
summary: string
eligibility: string
costLabel: string
sourceURL: string
sourceName: string
updatedAt: timestamp
expiresAt: timestamp?      // strongly recommended for expiring offers/events
location: {
  latitude: number
  longitude: number
}?
isActive: boolean
isDemo: boolean?
```

Authenticated clients can read active records. Client writes are denied.

## `landmarks/{landmarkId}`

```text
name: string
category: string
description: string
location: {
  latitude: number
  longitude: number
}
claimRadiusMeters: number
isActive: boolean
```

Authenticated clients can read active records. Client writes are denied.

## `users/{uid}/claims/{landmarkId}`

```text
landmarkId: string
landmarkName: string
claimedAt: timestamp
verificationMethod: "server-distance"
distanceMeters: integer
accuracyMeters: integer
```

Only the owning user can read claims. Writes are server-only.

## Data-quality rule

Every production resource shown by AI should have an identifiable source and an explicit freshness value. Expiring opportunities should also have an expiration value and should be disabled or excluded after expiration.
