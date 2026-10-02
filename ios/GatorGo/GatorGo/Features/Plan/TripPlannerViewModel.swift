import Foundation

@MainActor
final class TripPlannerViewModel: ObservableObject {
    @Published var landmarks: [Landmark] = []
    @Published var selectedLandmarkID: String?
    @Published var preference: PlanTripRequest.Preference = .balanced
    @Published var includeArrivalTime = false
    @Published var arrivalTime = Date().addingTimeInterval(3600)
    @Published var budgetNote = ""
    @Published var accessibilityNote = ""
    @Published private(set) var result: PlanTripResponse?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let firestore = FirestoreService.shared
    private let functions = FunctionsService.shared
    private let locationService = LocationService()

    var selectedLandmark: Landmark? {
        landmarks.first { $0.id == selectedLandmarkID }
    }

    func load() async {
        guard landmarks.isEmpty else { return }
        do {
            landmarks = try await firestore.loadLandmarks()
            selectedLandmarkID = landmarks.first?.id
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func plan() async {
        guard let destination = selectedLandmark else {
            errorMessage = "Choose a destination first."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let current = try await locationService.currentLocation()
            let request = PlanTripRequest(
                origin: Coordinate(latitude: current.coordinate.latitude, longitude: current.coordinate.longitude),
                destination: destination.location,
                destinationLabel: destination.name,
                arrivalTimeISO: includeArrivalTime ? arrivalTime.ISO8601Format() : nil,
                preference: preference,
                budgetNote: budgetNote.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                accessibilityNote: accessibilityNote.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
            )
            result = try await functions.planTrip(request)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
