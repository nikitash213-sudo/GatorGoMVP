import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        Group {
            switch auth.state {
            case .starting:
                ProgressView("Starting GatorGo…")
            case .signedIn:
                RootTabView()
            case .failed(let message):
                ContentUnavailableView(
                    "Could not start GatorGo",
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
            }
        }
    }
}
