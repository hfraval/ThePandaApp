import XCTest
import TPACore
import TPAAnalytics
import TPAFoundation
import TPAUnitTestFoundation
@testable import TPASettings

@MainActor
final class SettingsLogoutActionTests: AppTestCase {
    @MockResolved<SessionServiceProtocol, MockSessionService> var _session

    func test_perform_clearsSession() {
        _session.currentUser = .mock
        let logout = SettingsLogoutAction()
        logout()
        XCTAssertEqual(_session.clearSessionCallCount, 1)
    }

    func test_perform_postsSignedOutEvent() {
        let center = ServiceContainer.shared.resolve(NotificationCenter.self)
        var signedOut = false
        let token = center.addObserver(forName: AuthEvents.SignedOut.notificationName, object: nil, queue: nil) { _ in signedOut = true }
        defer { center.removeObserver(token) }

        let logout = SettingsLogoutAction()
        logout()

        XCTAssertTrue(signedOut)
    }
}

@MainActor
final class SettingsViewControllerTests: AppTestCase {
    func test_composesRows() {
        let vc = SettingsViewController()
        vc.loadViewIfNeeded()
        XCTAssertEqual(vc.content.count, 3)
    }

    func test_presentsEvent_onAppear() {
        let center = ServiceContainer.shared.resolve(NotificationCenter.self)
        var presented = false
        let token = center.addObserver(forName: SettingsEvents.Presented.notificationName, object: nil, queue: nil) { _ in presented = true }
        defer { center.removeObserver(token) }

        let vc = SettingsViewController()
        vc.loadViewIfNeeded()

        XCTAssertTrue(presented)
    }
}

@MainActor
final class SettingsTrackingTests: AppTestCase {
    @MockResolved<AnalyticsServiceProtocol, MockAnalyticsService> var _analytics

    private var processor: SettingsPresentedTrackingProcessor!

    func test_presentedEvent_tracks() {
        processor = SettingsPresentedTrackingProcessor()
        post(SettingsEvents.Presented())
        XCTAssertTrue(_analytics.hasTracked("settings_presented"))
    }
}
