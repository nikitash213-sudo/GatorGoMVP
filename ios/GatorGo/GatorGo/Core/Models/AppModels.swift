import Foundation

struct Coordinate: Codable, Hashable, Sendable {
    let latitude: Double
    let longitude: Double
}

struct ResourceItem: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let category: String
    let summary: String
    let eligibility: String
    let costLabel: String
    let sourceURL: String
    let sourceName: String
    let updatedAtISO: String
    let expiresAtISO: String?
    let location: Coordinate?
    let isActive: Bool
    let isDemo: Bool?

    var freshnessLabel: String {
        guard let date = ISO8601DateFormatter().date(from: updatedAtISO) else { return "Freshness unknown" }
        return "Updated \(date.formatted(date: .abbreviated, time: .omitted))"
    }
}

struct Landmark: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let category: String
    let description: String
    let location: Coordinate
    let claimRadiusMeters: Double
    let isActive: Bool
}

struct LandmarkClaim: Identifiable, Hashable, Sendable {
    let id: String
    let landmarkName: String
    let claimedAt: Date?
    let distanceMeters: Int
}

struct TransitRoute: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let durationText: String
    let distanceText: String
    let durationSeconds: Double
    let distanceMeters: Double
    let encodedPolyline: String?
    let transitSteps: [String]
}

struct AskNavigatorRequest: Codable, Sendable {
    let query: String
}

struct AskNavigatorResponse: Codable, Sendable {
    let answer: String
    let caveats: [String]
    let resources: [ResourceItem]
    let generatedAtISO: String
    let model: String
}

struct PlanTripRequest: Codable, Sendable {
    enum Preference: String, Codable, CaseIterable, Identifiable, Sendable {
        case balanced = "BALANCED"
        case lessWalking = "LESS_WALKING"
        case fewerTransfers = "FEWER_TRANSFERS"

        var id: String { rawValue }
        var title: String {
            switch self {
            case .balanced: "Balanced"
            case .lessWalking: "Less walking"
            case .fewerTransfers: "Fewer transfers"
            }
        }
    }

    let origin: Coordinate
    let destination: Coordinate
    let destinationLabel: String
    let arrivalTimeISO: String?
    let preference: Preference
    let budgetNote: String?
    let accessibilityNote: String?
}

struct PlanTripResponse: Codable, Sendable {
    let routes: [TransitRoute]
    let explanation: String
    let recommendedRouteId: String
    let caveats: [String]
    let resources: [ResourceItem]
    let generatedAtISO: String
    let model: String
}

struct ClaimLandmarkRequest: Codable, Sendable {
    let landmarkId: String
    let location: Coordinate
    let accuracyMeters: Double
}

struct ClaimLandmarkResponse: Codable, Sendable {
    let landmarkId: String
    let landmarkName: String
    let distanceMeters: Int
    let claimed: Bool
}
