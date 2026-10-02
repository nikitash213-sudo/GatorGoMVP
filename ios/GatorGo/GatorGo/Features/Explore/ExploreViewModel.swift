import Foundation

@MainActor
final class ExploreViewModel: ObservableObject {
    @Published private(set) var landmarks: [Landmark] = []
    @Published private(set) var claims: [LandmarkClaim] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let locationService = LocationService()

    var claimedIDs: Set<String> { Set(claims.map(\.id)) }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let landmarksTask = FirestoreService.shared.loadLandmarks()
            async let claimsTask = FirestoreService.shared.loadClaims()
            landmarks = try await landmarksTask
            claims = try await claimsTask
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func claim(_ landmark: Landmark) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        defer { isLoading = false }

        do {
            let location = try await locationService.currentLocation()
            let request = ClaimLandmarkRequest(
                landmarkId: landmark.id,
                location: Coordinate(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                ),
                accuracyMeters: max(location.horizontalAccuracy, 1)
            )
            let result = try await FunctionsService.shared.claimLandmark(request)
            successMessage = "Claimed \(result.landmarkName) from \(result.distanceMeters) m away."
            claims = try await FirestoreService.shared.loadClaims()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
