import XCTest
import TPACore
import TPAAnalytics
import TPAFoundation
import TPAUnitTestFoundation
@testable import TPAAuth

@MainActor
final class ValidateLoginCommandTests: AppTestCase {
    private let validate = ValidateLoginCommand()

    func test_validCredentials() {
        XCTAssertTrue(validate(email: "test@example.com", password: "password123"))
    }

    func test_invalidEmail() {
        XCTAssertFalse(validate(email: "bad", password: "password123"))
    }

    func test_shortPassword() {
        XCTAssertFalse(validate(email: "test@example.com", password: "abc"))
    }

    func test_emptyFields() {
        XCTAssertFalse(validate(email: "", password: ""))
    }
}

@MainActor
final class LoginActionTests: AppTestCase {
    @MockResolved<AuthServiceProtocol, MockAuthService> var _auth
    @MockResolved<SessionServiceProtocol, MockSessionService> var _session

    private var action: LoginAction!

    override func setUp() async throws {
        try await super.setUp()
        action = LoginAction()
    }

    override func tearDown() async throws {
        action = nil
        try await super.tearDown()
    }

    private func performAndDrain(email: String, password: String) async {
        action(email: email, password: password)
        await Task.yield()
        try? await Task.sleep(nanoseconds: 30_000_000)
    }

    func test_validCredentials_callsAuthService() async {
        _auth.loginResult = .success(.mock)
        await performAndDrain(email: "test@example.com", password: "password123")
        XCTAssertEqual(_auth.loginCallCount, 1)
        XCTAssertEqual(_auth.lastLoginEmail, "test@example.com")
    }

    func test_success_storesUserInSession() async {
        _auth.loginResult = .success(.mock)
        await performAndDrain(email: "test@example.com", password: "password123")
        XCTAssertEqual(_session.currentUser?.id, User.mock.id)
    }

    func test_success_postsSignedInEvent() async {
        _auth.loginResult = .success(.mock)
        let center = ServiceContainer.shared.resolve(NotificationCenter.self)
        var receivedUser: User?
        let token = center.addObserver(forName: AuthEvents.SignedIn.notificationName, object: nil, queue: nil) { note in
            receivedUser = (note.eventPayload() as AuthEvents.SignedIn?)?.user
        }
        defer { center.removeObserver(token) }

        await performAndDrain(email: "test@example.com", password: "password123")

        XCTAssertEqual(receivedUser?.id, User.mock.id)
    }

    func test_failure_doesNotSetSession() async {
        _auth.loginResult = .failure(.invalidCredentials)
        await performAndDrain(email: "test@example.com", password: "password123")
        XCTAssertNil(_session.currentUser)
    }

    func test_invalidEmail_doesNotCallAuthService() async {
        await performAndDrain(email: "bad-email", password: "password123")
        XCTAssertEqual(_auth.loginCallCount, 0)
    }

    func test_shortPassword_doesNotCallAuthService() async {
        await performAndDrain(email: "test@example.com", password: "abc")
        XCTAssertEqual(_auth.loginCallCount, 0)
    }
}

@MainActor
final class LoginViewModelProviderTests: AppTestCase {
    private var provider: LoginViewModelProvider!

    override func setUp() async throws {
        try await super.setUp()
        provider = LoginViewModelProvider()
    }

    override func tearDown() async throws {
        provider = nil
        try await super.tearDown()
    }

    private var current: LoginViewModel { provider.viewModel }

    /// Events reach the provider through an `AsyncStream` consumed on a `Task`, so let the run loop
    /// drain after posting before reading the observable view model.
    private func drain() async {
        await Task.yield()
        try? await Task.sleep(nanoseconds: 30_000_000)
    }

    func test_initial_isIdle() {
        XCTAssertEqual(current, .idle)
    }

    func test_submittingEvent_isLoading() async {
        post(LoginEvents.Submitting())
        await drain()
        XCTAssertEqual(current, .loading)
    }

    func test_failedEvent_isError() async {
        post(LoginEvents.Submitting())
        post(LoginEvents.Failed(reason: "Nope"))
        await drain()
        XCTAssertEqual(current, .error(message: "Nope"))
    }
}
