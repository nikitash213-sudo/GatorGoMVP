import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack { TripPlannerView() }
                .tabItem { Label("Plan", systemImage: "arrow.triangle.turn.up.right.diamond") }

            NavigationStack { ResourcesView() }
                .tabItem { Label("Resources", systemImage: "books.vertical") }

            NavigationStack { AskNavigatorView() }
                .tabItem { Label("Ask", systemImage: "sparkles") }

            NavigationStack { ExploreView() }
                .tabItem { Label("Explore", systemImage: "map") }

            NavigationStack { ProfileView() }
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}
