import XCTest
import TPACore
import TPAUnitTestFoundation
@testable import TPAProfile

@MainActor
final class ProfileScreenshotTests: ScreenshotTestCase {
    @MockResolved<ProfileServiceProtocol, MockProfileService> var _profile
    @MockResolved<SessionServiceProtocol, MockSessionService> var _session

    override func setUp() async throws {
        try await super.setUp()
        _session.currentUser = .mock
    }

    func test_profileScreen_withData() {
        _profile.profile = .mock
        assertAppearance { ProfileViewController() }
    }

    func test_profileScreen_emptyProfile() {
        _profile.profile = UserProfile(userId: "2", firstName: "", lastName: "", email: "")
        assertAppearance { ProfileViewController() }
    }

    func test_profileScreen_tabBarDocked() {
        _profile.profile = .mock
        assertAppearance(afterLayout: { vc in
            firstScrollView(in: vc.view)?.contentOffset.y = 600
        }) {
            ProfileViewController()
        }
    }
}

@MainActor
private func firstScrollView(in view: UIView) -> UIScrollView? {
    if let scrollView = view as? UIScrollView { return scrollView }
    for subview in view.subviews {
        if let found = firstScrollView(in: subview) { return found }
    }
    return nil
}
