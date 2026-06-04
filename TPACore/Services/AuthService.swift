import Foundation
import TPALogging

@MainActor
public final class AuthService: AuthServiceProtocol {
    private var currentUser: User?
    private let logger: LoggerProtocol

    public init(logger: LoggerProtocol) {
        self.logger = logger
    }

    public func login(email: String, password: String) async -> AuthResult {
        logger.info("Login attempt for: \(email)")
        try? await Task.sleep(nanoseconds: 500_000_000)

        guard !email.trimmed.isEmpty, !password.trimmed.isEmpty else {
            logger.warning("Login failed: empty credentials")
            return .failure(.invalidCredentials)
        }

        let user = User(id: UUID().uuidString, email: email)
        currentUser = user
        logger.info("Login successful: \(user.id)")
        return .success(user)
    }

    public func logout() async -> Result<Void, AuthError> {
        logger.info("Logout: \(currentUser?.id ?? "none")")
        currentUser = nil
        return .success(())
    }

    public func isAuthenticated() -> Bool {
        currentUser != nil
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
