import XCTest
import TPAAnalytics
import TPAFoundation
import TPAUnitTestFoundation
@testable import TPADiscovery

@MainActor
final class DiscoveryTrackingTests: AppTestCase {
    @MockResolved<AnalyticsServiceProtocol, MockAnalyticsService> var _analytics

    private var processor: DiscoveryViewedTrackingProcessor!

    func test_appearedEvent_tracksDiscoveryViewed() {
        processor = DiscoveryViewedTrackingProcessor()

        post(DiscoveryEvents.Appeared())

        XCTAssertTrue(_analytics.hasTracked("discovery_viewed"))
    }

    func test_appearedEvent_tracksOncePerPost() {
        processor = DiscoveryViewedTrackingProcessor()

        post(DiscoveryEvents.Appeared())
        post(DiscoveryEvents.Appeared())

        let count = _analytics.trackedEvents.filter { $0.name == "discovery_viewed" }.count
        XCTAssertEqual(count, 2)
    }
}
