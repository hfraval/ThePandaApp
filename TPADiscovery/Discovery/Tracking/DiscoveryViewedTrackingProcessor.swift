import TPAAnalytics
import TPAFoundation

public final class DiscoveryViewedTrackingProcessor: EventProcessor<DiscoveryEvents.Appeared> {
    @Resolved private var analytics: AnalyticsServiceProtocol

    public override func handle(_ event: DiscoveryEvents.Appeared) {
        analytics.track(.discoveryViewed())
    }
}
