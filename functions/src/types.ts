export type LatLng = {
  latitude: number;
  longitude: number;
};

export type ResourceRecord = {
  id: string;
  title: string;
  category: string;
  summary: string;
  eligibility: string;
  costLabel: string;
  sourceURL: string;
  sourceName: string;
  updatedAtISO: string;
  expiresAtISO?: string;
  location?: LatLng;
  isActive: boolean;
  isDemo?: boolean;
};

export type LandmarkRecord = {
  id: string;
  name: string;
  category: string;
  description: string;
  location: LatLng;
  claimRadiusMeters: number;
  isActive: boolean;
};

export type RouteSummary = {
  id: string;
  durationText: string;
  distanceText: string;
  durationSeconds: number;
  distanceMeters: number;
  encodedPolyline?: string;
  transitSteps: string[];
};
