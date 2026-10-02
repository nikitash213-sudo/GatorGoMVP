import SwiftUI

@main
struct GatorGoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var authService = AuthService()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(authService)
                .task {
                    await authService.bootstrap()
                }
        }
    }
}
