import Foundation
import TPACore

public final class MockAuthService: AuthServiceProtocol, @unchecked Sendable {
    public var loginResult: AuthResult = .success(.mock)
    public var logoutResult: Result<Void, AuthError> = .success(())
    public var isAuthenticatedValue: Bool = false

    public private(set) var loginCallCount = 0
    public private(set) var logoutCallCount = 0
    public private(set) var lastLoginEmail: String?
    public private(set) var lastLoginPassword: String?

    public init() {}

    public func login(email: String, password: String) async -> AuthResult {
        loginCallCount += 1
        lastLoginEmail = email
        lastLoginPassword = password
        return loginResult
    }

    public func logout() async -> Result<Void, AuthError> {
        logoutCallCount += 1
        return logoutResult
    }

    public func isAuthenticated() -> Bool {
        isAuthenticatedValue
    }
}
