import XCTest
import TPACore
import TPAFoundation
import TPAUIKit
import TPAUnitTestFoundation
@testable import TPAAuth

@MainActor
private final class CaptureLoginDelegate: ViewModelProviderDelegate {
    var latest: LoginViewModel?
    func viewModelUpdated(_ viewModel: LoginViewModel) { latest = viewModel }
}

@MainActor
final class LoginLoadingResetTests: AppTestCase {
    private var provider: LoginViewModelProvider!
    private var capture: CaptureLoginDelegate!
    private var anyDelegate: AnyViewModelProviderDelegate<LoginViewModel>!

    override func setUp() async throws {
        try await super.setUp()
        provider = LoginViewModelProvider()
        capture = CaptureLoginDelegate()
        anyDelegate = AnyViewModelProviderDelegate(capture)
        provider.delegate = anyDelegate
    }

    override func tearDown() async throws {
        provider = nil; capture = nil; anyDelegate = nil
        try await super.tearDown()
    }

    /// Events now reach the provider through an `AsyncStream` consumed on a `Task`, so let the
    /// run loop drain after posting before asserting on the pushed view model.
    private func drain() async {
        await Task.yield()
        try? await Task.sleep(nanoseconds: 30_000_000)
    }

    func test_submitting_thenSucceeded_clearsLoading() async {
        post(LoginEvents.Submitting())
        await drain()
        XCTAssertTrue(capture.latest?.isLoading == true)

        post(LoginEvents.Succeeded(userId: "1"))
        await drain()
        XCTAssertFalse(capture.latest?.isLoading == true)
    }

    func test_signedOut_resetsToIdle() async {
        post(LoginEvents.Submitting())
        post(AuthEvents.SignedOut())
        await drain()
        XCTAssertFalse(capture.latest?.isLoading == true)
        XCTAssertNil(capture.latest?.errorMessage)
    }
}
