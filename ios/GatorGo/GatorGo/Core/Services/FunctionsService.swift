import FirebaseFunctions
import Foundation

final class FunctionsService: Sendable {
    static let shared = FunctionsService()
    private let functions = Functions.functions(region: "us-west1")

    func askNavigator(query: String) async throws -> AskNavigatorResponse {
        let callable: Callable<AskNavigatorRequest, AskNavigatorResponse> = functions.httpsCallable("askNavigator")
        return try await callable(AskNavigatorRequest(query: query))
    }

    func planTrip(_ request: PlanTripRequest) async throws -> PlanTripResponse {
        let callable: Callable<PlanTripRequest, PlanTripResponse> = functions.httpsCallable("planTrip")
        return try await callable(request)
    }

    func claimLandmark(_ request: ClaimLandmarkRequest) async throws -> ClaimLandmarkResponse {
        let callable: Callable<ClaimLandmarkRequest, ClaimLandmarkResponse> = functions.httpsCallable("claimLandmark")
        return try await callable(request)
    }
}
