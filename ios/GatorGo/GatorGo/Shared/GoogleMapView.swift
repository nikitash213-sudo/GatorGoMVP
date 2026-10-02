import GoogleMaps
import SwiftUI

struct GoogleMapView: UIViewRepresentable {
    var landmarks: [Landmark] = []
    var routePolyline: String? = nil
    var focusedCoordinate: Coordinate? = nil

    func makeUIView(context: Context) -> GMSMapView {
        let fallback = focusedCoordinate ?? landmarks.first?.location ?? Coordinate(latitude: 37.7219, longitude: -122.4782)
        let camera = GMSCameraPosition(latitude: fallback.latitude, longitude: fallback.longitude, zoom: 15)
        return GMSMapView(frame: .zero, camera: camera)
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        mapView.clear()

        for landmark in landmarks {
            let marker = GMSMarker(position: CLLocationCoordinate2D(
                latitude: landmark.location.latitude,
                longitude: landmark.location.longitude
            ))
            marker.title = landmark.name
            marker.snippet = landmark.category.capitalized
            marker.map = mapView
        }

        if let routePolyline, let path = GMSPath(fromEncodedPath: routePolyline) {
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 5
            polyline.map = mapView
        }

        if let focusedCoordinate {
            mapView.animate(to: GMSCameraPosition(
                latitude: focusedCoordinate.latitude,
                longitude: focusedCoordinate.longitude,
                zoom: 15
            ))
        }
    }
}
