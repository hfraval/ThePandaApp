import XCTest
import TPAFoundation
import TPALogging
import TPACore
import TPAUnitTestFoundation

/// Verifies the unauthorized-session policy: a 401 signal is observed and logged, but with mock
/// auth it must **not** sign the user out. This is the regression guard against re-introducing the
/// old "any 401 → clear session" behavior.
@MainActor
final class UnauthorizedPolicyProcessorTests: AppTestCase {
    private var processor: UnauthorizedPolicyProcessor!

    override func setUp() async throws {
        try await super.setUp()
        processor = UnauthorizedPolicyProcessor()
    }

    override func tearDown() async throws {
        processor = nil
        try await super.tearDown()
    }

    private var session: MockSessionService {
        ServiceContainer.shared.resolve(SessionServiceProtocol.self) as! MockSessionService
    }

    private var logger: MockLogger {
        ServiceContainer.shared.resolve(LoggerProtocol.self) as! MockLogger
    }

    func test_unauthorized_doesNotClearSession() {
        session.setUser(User(id: "1", email: "a@b.com"))

        post(AuthEvents.Unauthorized())

        XCTAssertEqual(session.clearSessionCallCount, 0)
        XCTAssertNotNil(session.currentUser)
    }

    func test_unauthorized_logsWarning() {
        post(AuthEvents.Unauthorized())

        XCTAssertTrue(logger.messages.contains { $0.1 == .warning })
    }
}
