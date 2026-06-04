import XCTest
import TPACore
import TPAFoundation
import TPAUnitTestFoundation
@testable import TPAAuth

@MainActor
final class LoginLoadingResetTests: AppTestCase {
    private var provider: LoginViewModelProvider!

    override func setUp() async throws {
        try await super.setUp()
        provider = LoginViewModelProvider()
    }

    override func tearDown() async throws {
        provider = nil
        try await super.tearDown()
    }

    /// Events now reach the provider through an `AsyncStream` consumed on a `Task`, so let the
    /// run loop drain after posting before reading the observable view model.
    private func drain() async {
        await Task.yield()
        try? await Task.sleep(nanoseconds: 30_000_000)
    }

    func test_submitting_thenSucceeded_returnsToIdle() async {
        post(LoginEvents.Submitting())
        await drain()
        XCTAssertEqual(provider.viewModel, .loading)

        post(LoginEvents.Succeeded(userId: "1"))
        await drain()
        XCTAssertEqual(provider.viewModel, .idle)
    }

    func test_signedOut_resetsToIdle() async {
        post(LoginEvents.Submitting())
        post(AuthEvents.SignedOut())
        await drain()
        XCTAssertEqual(provider.viewModel, .idle)
    }
}
