import FirebaseAuth
import FirebaseFirestore
import Foundation

final class FirestoreService: @unchecked Sendable {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    func loadResources() async throws -> [ResourceItem] {
        let snapshot = try await db.collection("resources")
            .whereField("isActive", isEqualTo: true)
            .getDocuments()

        return snapshot.documents.compactMap(Self.resource(from:))
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    func loadLandmarks() async throws -> [Landmark] {
        let snapshot = try await db.collection("landmarks")
            .whereField("isActive", isEqualTo: true)
            .getDocuments()

        return snapshot.documents.compactMap(Self.landmark(from:))
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func loadClaims() async throws -> [LandmarkClaim] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        let snapshot = try await db.collection("users").document(uid)
            .collection("claims")
            .order(by: "claimedAt", descending: true)
            .getDocuments()

        return snapshot.documents.map { document in
            let data = document.data()
            return LandmarkClaim(
                id: document.documentID,
                landmarkName: data["landmarkName"] as? String ?? "Landmark",
                claimedAt: (data["claimedAt"] as? Timestamp)?.dateValue(),
                distanceMeters: data["distanceMeters"] as? Int ?? 0
            )
        }
    }

    private static func resource(from document: QueryDocumentSnapshot) -> ResourceItem? {
        let data = document.data()
        guard
            let title = data["title"] as? String,
            let category = data["category"] as? String,
            let summary = data["summary"] as? String,
            let eligibility = data["eligibility"] as? String,
            let costLabel = data["costLabel"] as? String,
            let sourceURL = data["sourceURL"] as? String,
            let sourceName = data["sourceName"] as? String
        else { return nil }

        let location: Coordinate?
        if let map = data["location"] as? [String: Any],
           let latitude = map["latitude"] as? Double,
           let longitude = map["longitude"] as? Double {
            location = Coordinate(latitude: latitude, longitude: longitude)
        } else {
            location = nil
        }

        let updatedAtISO = (data["updatedAt"] as? Timestamp)?.dateValue().ISO8601Format()
            ?? (data["updatedAtISO"] as? String)
            ?? Date.distantPast.ISO8601Format()
        let expiresAtISO = (data["expiresAt"] as? Timestamp)?.dateValue().ISO8601Format()
            ?? data["expiresAtISO"] as? String

        return ResourceItem(
            id: document.documentID,
            title: title,
            category: category,
            summary: summary,
            eligibility: eligibility,
            costLabel: costLabel,
            sourceURL: sourceURL,
            sourceName: sourceName,
            updatedAtISO: updatedAtISO,
            expiresAtISO: expiresAtISO,
            location: location,
            isActive: data["isActive"] as? Bool ?? true,
            isDemo: data["isDemo"] as? Bool
        )
    }

    private static func landmark(from document: QueryDocumentSnapshot) -> Landmark? {
        let data = document.data()
        guard
            let name = data["name"] as? String,
            let category = data["category"] as? String,
            let description = data["description"] as? String,
            let map = data["location"] as? [String: Any],
            let latitude = map["latitude"] as? Double,
            let longitude = map["longitude"] as? Double
        else { return nil }

        return Landmark(
            id: document.documentID,
            name: name,
            category: category,
            description: description,
            location: Coordinate(latitude: latitude, longitude: longitude),
            claimRadiusMeters: data["claimRadiusMeters"] as? Double ?? 100,
            isActive: data["isActive"] as? Bool ?? true
        )
    }
}
