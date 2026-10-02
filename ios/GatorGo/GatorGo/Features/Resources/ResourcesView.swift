import SwiftUI

struct ResourcesView: View {
    @StateObject private var model = ResourcesViewModel()

    var body: some View {
        List {
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
        .navigationTitle("Resources")
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
