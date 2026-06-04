import TPAAnalytics
import TPAFoundation

public final class SettingsPresentedTrackingProcessor: EventProcessor<SettingsEvents.Presented> {
    @Resolved private var analytics: AnalyticsServiceProtocol

    public override func handle(_ event: SettingsEvents.Presented) {
        analytics.track(AnalyticsEvent(name: "settings_presented"))
    }
}
