import Foundation
import TPALogging

@MainActor
public final class SessionService: SessionServiceProtocol {
    private static let storageKey = "session.currentUser"

    public private(set) var currentUser: User?
    private let storage: LocalStorageServiceProtocol
    private let logger: LoggerProtocol

    public init(storage: LocalStorageServiceProtocol, logger: LoggerProtocol) {
        self.storage = storage
        self.logger = logger
        currentUser = storage.load(User.self, forKey: Self.storageKey)
        if let currentUser {
            logger.info("Session restored for user: \(currentUser.id)")
        }
    }

    public func setUser(_ user: User?) {
        currentUser = user
        if let user {
            storage.save(user, forKey: Self.storageKey)
            logger.info("Session set for user: \(user.id)")
        } else {
            storage.remove(forKey: Self.storageKey)
            logger.info("Session cleared")
        }
    }

    public func clearSession() {
        logger.info("Clearing session: \(currentUser?.id ?? "none")")
        currentUser = nil
        storage.remove(forKey: Self.storageKey)
    }
}
