import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var auth: AuthService
    @State private var isResetting = false

    var body: some View {
        List {
            Section {
                CampusHeader(
                    eyebrow: "San Francisco State",
                    title: "Your GatorGo",
                    subtitle: "Session details and the safeguards behind your campus data.",
                    systemImage: "person.crop.circle.fill"
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section("Demo session") {
                LabeledContent("Authentication", value: "Firebase anonymous auth")
                if let uid = auth.userID {
                    LabeledContent("User ID", value: String(uid.prefix(10)) + "…")
                }
                Button("Reset demo session", role: .destructive) {
                    Task {
                        isResetting = true
                        await auth.resetDemoSession()
                        isResetting = false
                    }
                }
                .disabled(isResetting)
            }

            Section("Security model") {
                Label("Gemini and Routes API keys stay on the server", systemImage: "key.fill")
                Label("Callable APIs require Firebase Auth and App Check", systemImage: "checkmark.shield.fill")
                Label("Firestore catalog writes are server-only", systemImage: "lock.fill")
            }

            Section("MVP note") {
                Text("The included seed records and campus coordinates are intentionally marked as demo data. Replace them with verified SFSU records and official freshness/expiration policies before a public launch.")
            }
        }
        .scrollContentBackground(.hidden)
        .background(GatorGoTheme.canvas)
        .tint(GatorGoTheme.purple)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}
