import Foundation
import TPACore

public final class MockSessionService: SessionServiceProtocol, @unchecked Sendable {
    public var currentUser: User?

    public private(set) var setUserCallCount = 0
    public private(set) var clearSessionCallCount = 0

    public init() {}

    public func setUser(_ user: User?) {
        currentUser = user
        setUserCallCount += 1
    }

    public func clearSession() {
        currentUser = nil
        clearSessionCallCount += 1
    }
}
