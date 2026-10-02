import FirebaseAppCheck
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFunctions
import GoogleMaps
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppCheck.setAppCheckProviderFactory(GatorGoAppCheckProviderFactory())
        FirebaseApp.configure()

        if let mapsKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_IOS_API_KEY") as? String,
           !mapsKey.isEmpty,
           !mapsKey.contains("YOUR_") {
            GMSServices.provideAPIKey(mapsKey)
        }

        #if DEBUG
        if ProcessInfo.processInfo.environment["USE_FIREBASE_EMULATORS"] == "1" {
            Auth.auth().useEmulator(withHost: "127.0.0.1", port: 9099)
            Firestore.firestore().useEmulator(withHost: "127.0.0.1", port: 8080)
            Functions.functions(region: "us-west1").useEmulator(withHost: "127.0.0.1", port: 5001)
        }
        #endif

        return true
    }
}
