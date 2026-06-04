import Foundation
import TPACore
import TPAFoundation

@MainActor
protocol LoginServiceProtocol {
    func login(email: String, password: String) async
}

@MainActor
final class LoginService: LoginServiceProtocol {
    @Resolved private var authService: AuthServiceProtocol
    @Resolved private var sessionService: SessionServiceProtocol

    func login(email: String, password: String) async {
        post(LoginEvents.Submitting())
        post(LoginEvents.Attempted(email: email))

        let result = await authService.login(email: email, password: password)

        switch result {
        case .success(let user):
            sessionService.setUser(user)
            post(LoginEvents.Succeeded(userId: user.id))
            post(AuthEvents.SignedIn(user: user))

        case .failure(let error):
            post(LoginEvents.Failed(reason: message(for: error)))
        }
    }

    private func message(for error: AuthError) -> String {
        switch error {
        case .invalidCredentials: return localize("login.error.invalidCredentials")
        case .networkError: return localize("login.error.networkError")
        case .unknown: return localize("login.error.unknown")
        }
    }
}
