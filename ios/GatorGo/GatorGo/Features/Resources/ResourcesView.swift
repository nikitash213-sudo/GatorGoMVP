import SwiftUI

struct ResourcesView: View {
    @StateObject private var model = ResourcesViewModel()

    var body: some View {
        List {
            Section {
                CampusHeader(
                    eyebrow: "San Francisco State",
                    title: "Campus resources",
                    subtitle: "Browse practical support and verify details at the source.",
                    systemImage: "books.vertical.fill"
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            if model.isLoading && model.resources.isEmpty {
                ProgressView("Loading verified records…")
            }

            ForEach(model.filtered) { resource in
                NavigationLink {
                    ResourceDetailView(resource: resource)
                } label: {
                    ResourceCard(resource: resource)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(GatorGoTheme.canvas)
        .tint(GatorGoTheme.purple)
        .navigationTitle("Resources")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $model.searchText, prompt: "Search category or need")
        .refreshable { await model.load() }
        .task { await model.load() }
        .overlay {
            if !model.isLoading && model.filtered.isEmpty {
                ContentUnavailableView.search(text: model.searchText)
            }
        }
        .alert("Could not load resources", isPresented: .constant(model.errorMessage != nil)) {
            Button("OK") { model.errorMessage = nil }
        } message: {
            Text(model.errorMessage ?? "")
        }
    }
}
