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

    func test_submitting_thenSucceeded_clearsLoading() {
        post(LoginEvents.Submitting())
        XCTAssertTrue(capture.latest?.isLoading == true)

        post(LoginEvents.Succeeded(userId: "1"))
        XCTAssertFalse(capture.latest?.isLoading == true)
    }

    func test_signedOut_resetsToIdle() {
        post(LoginEvents.Submitting())
        post(AuthEvents.SignedOut())
        XCTAssertFalse(capture.latest?.isLoading == true)
        XCTAssertNil(capture.latest?.errorMessage)
    }
}
