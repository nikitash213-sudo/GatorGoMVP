import Foundation

@MainActor
final class AskNavigatorViewModel: ObservableObject {
    @Published var question = ""
    @Published private(set) var response: AskNavigatorResponse?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    func ask() async {
        let trimmed = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 3 else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            response = try await FunctionsService.shared.askNavigator(query: trimmed)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
