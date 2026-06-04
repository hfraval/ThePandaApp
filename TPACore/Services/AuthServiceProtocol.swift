import Foundation

public enum AuthError: Error, Sendable {
    case invalidCredentials
    case networkError
    case unknown
}

public typealias AuthResult = Result<User, AuthError>

@MainActor
public protocol AuthServiceProtocol: Sendable {
    func login(email: String, password: String) async -> AuthResult
    func logout() async -> Result<Void, AuthError>
    func isAuthenticated() -> Bool
}
