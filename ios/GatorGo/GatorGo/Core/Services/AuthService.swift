import FirebaseAuth
import Foundation

@MainActor
final class AuthService: ObservableObject {
    enum State: Equatable {
        case starting
        case signedIn(uid: String)
        case failed(String)
    }

    @Published private(set) var state: State = .starting

    var userID: String? {
        if case .signedIn(let uid) = state { return uid }
        return nil
    }

    func bootstrap() async {
        do {
            if let current = Auth.auth().currentUser {
                state = .signedIn(uid: current.uid)
                return
            }
            let result = try await Auth.auth().signInAnonymously()
            state = .signedIn(uid: result.user.uid)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func resetDemoSession() async {
        do {
            try Auth.auth().signOut()
            state = .starting
            let result = try await Auth.auth().signInAnonymously()
            state = .signedIn(uid: result.user.uid)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
