@preconcurrency import CoreLocation
import Foundation

@MainActor
final class LocationService: NSObject, ObservableObject {

    enum LocationError: LocalizedError {
        case permissionDenied
        case unavailable
        case requestAlreadyInFlight

        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Location permission is required for this action."

            case .unavailable:
                return "A location fix is not available yet. In Simulator, choose Features > Location > Apple. On iPhone, enable Location Services and try again outdoors."

            case .requestAlreadyInFlight:
                return "A location request is already in progress."
            }
        }
    }

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?
    private var locationUnknownRetries = 0

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func currentLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            guard self.continuation == nil else {
                continuation.resume(
                    throwing: LocationError.requestAlreadyInFlight
                )
                return
            }

            self.continuation = continuation
            self.locationUnknownRetries = 0

            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()

            case .authorizedAlways, .authorizedWhenInUse:
                manager.requestLocation()

            case .denied, .restricted:
                finish(
                    with: .failure(
                        LocationError.permissionDenied
                    )
                )

            @unknown default:
                finish(
                    with: .failure(
                        LocationError.unavailable
                    )
                )
            }
        }
    }

    private func finish(
        with result: Result<CLLocation, Error>
    ) {
        guard let continuation else {
            return
        }

        self.continuation = nil

        switch result {
        case .success(let location):
            continuation.resume(returning: location)

        case .failure(let error):
            continuation.resume(throwing: error)
        }
    }
}

extension LocationService: @preconcurrency CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        guard continuation != nil else {
            return
        }

        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()

        case .denied, .restricted:
            finish(
                with: .failure(
                    LocationError.permissionDenied
                )
            )

        case .notDetermined:
            break

        @unknown default:
            finish(
                with: .failure(
                    LocationError.unavailable
                )
            )
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else {
            finish(
                with: .failure(
                    LocationError.unavailable
                )
            )
            return
        }

        finish(
            with: .success(location)
        )
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        if let locationError = error as? CLError {
            switch locationError.code {
            case .locationUnknown where locationUnknownRetries == 0:
                locationUnknownRetries += 1
                Task { @MainActor [weak self] in
                    try? await Task.sleep(for: .seconds(1))
                    guard let self, self.continuation != nil else { return }
                    self.manager.requestLocation()
                }
                return

            case .locationUnknown:
                finish(with: .failure(LocationError.unavailable))
                return

            case .denied:
                finish(with: .failure(LocationError.permissionDenied))
                return

            default:
                break
            }
        }

        finish(
            with: .failure(error)
        )
    }
}