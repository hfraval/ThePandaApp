import XCTest
import TPAAnalytics
import TPAFoundation
import TPAUnitTestFoundation
@testable import TPAProfile

@MainActor
final class ProfileTrackingTests: AppTestCase {
    @MockResolved<AnalyticsServiceProtocol, MockAnalyticsService> var _analytics

    private var processor: ProfileTrackingProcessor!

    func test_viewedEvent_tracksProfileViewed() {
        processor = ProfileTrackingProcessor()

        post(ProfileEvents.Viewed(userId: "test-user"))

        XCTAssertTrue(_analytics.hasTracked("profile_viewed"))
    }
}
