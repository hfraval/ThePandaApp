import TPAAnalytics
import TPAFoundation

public final class ProfileTrackingProcessor: EventProcessor<ProfileEvents.Viewed> {
    @Resolved private var analytics: AnalyticsServiceProtocol

    public override func handle(_ event: ProfileEvents.Viewed) {
        analytics.track(.profileViewed(userId: event.userId))
    }
}
