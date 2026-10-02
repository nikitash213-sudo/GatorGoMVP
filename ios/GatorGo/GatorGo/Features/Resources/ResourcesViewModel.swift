import Foundation

@MainActor
final class ResourcesViewModel: ObservableObject {
    @Published private(set) var resources: [ResourceItem] = []
    @Published var searchText = ""
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    var filtered: [ResourceItem] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return resources }
        let query = searchText.lowercased()
        return resources.filter {
            $0.title.lowercased().contains(query) ||
            $0.category.lowercased().contains(query) ||
            $0.summary.lowercased().contains(query)
        }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            resources = try await FirestoreService.shared.loadResources()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
