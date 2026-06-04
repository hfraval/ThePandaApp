import XCTest
import TPACore
import TPAFoundation
import TPAUIKit
import TPAUnitTestFoundation
@testable import TPAProfile

@MainActor
private final class CaptureDelegate: ViewModelProviderDelegate {
    var latest: ProfilePersonalDetailsViewModel?
    func viewModelUpdated(_ viewModel: ProfilePersonalDetailsViewModel) { latest = viewModel }
}

@MainActor
final class LoadProfileActionTests: AppTestCase {
    @MockResolved<ProfileServiceProtocol, MockProfileService> var _profile
    @MockResolved<SessionServiceProtocol, MockSessionService> var _session

    override func setUp() async throws {
        try await super.setUp()
        _session.currentUser = .mock
    }

    private func performAndDrain() async {
        LoadProfileAction()()
        await Task.yield()
        try? await Task.sleep(nanoseconds: 30_000_000)
    }

    func test_perform_refreshesProfileService() async {
        await performAndDrain()
        XCTAssertEqual(_profile.refreshCallCount, 1)
    }

    func test_perform_postsViewedEvent() async {
        let center = ServiceContainer.shared.resolve(NotificationCenter.self)
        var viewed = false
        let token = center.addObserver(forName: ProfileEvents.Viewed.notificationName, object: nil, queue: nil) { _ in viewed = true }
        defer { center.removeObserver(token) }

        await performAndDrain()

        XCTAssertTrue(viewed)
    }
}

@MainActor
final class ProfileViewModelProviderTests: AppTestCase {
    @MockResolved<ProfileServiceProtocol, MockProfileService> var _profile

    private var provider: ProfileViewModelProvider<ProfilePersonalDetailsViewModel>!
    private var capture: CaptureDelegate!
    private var anyDelegate: AnyViewModelProviderDelegate<ProfilePersonalDetailsViewModel>!

    override func setUp() async throws {
        try await super.setUp()
        provider = ProfileViewModelProvider<ProfilePersonalDetailsViewModel>()
        capture = CaptureDelegate()
        anyDelegate = AnyViewModelProviderDelegate(capture)
        provider.delegate = anyDelegate
    }

    override func tearDown() async throws {
        provider = nil; capture = nil; anyDelegate = nil
        try await super.tearDown()
    }

    func test_updated_buildsViewModelFromService() {
        _profile.profile = .mock
        post(ProfileEvents.Updated())
        XCTAssertEqual(capture.latest?.name, UserProfile.mock.fullName)
        XCTAssertEqual(capture.latest?.email, UserProfile.mock.email)
    }

    func test_emptyProfile_usesPlaceholder() {
        _profile.profile = UserProfile(userId: "x", firstName: "", lastName: "", email: "")
        post(ProfileEvents.Updated())
        XCTAssertTrue(capture.latest?.name.isEmpty == true)
        XCTAssertFalse(capture.latest?.displayName.isEmpty == true)
        XCTAssertFalse(capture.latest?.showEmail == true)
    }
}
