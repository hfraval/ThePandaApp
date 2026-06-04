import TPAAnalytics
import TPAFoundation

public final class LoginTrackingProcessor {
    private let attempted: LoginAttemptedTrackingProcessor
    private let succeeded: LoginSucceededTrackingProcessor
    private let failed: LoginFailedTrackingProcessor

    public init() {
        attempted = LoginAttemptedTrackingProcessor()
        succeeded = LoginSucceededTrackingProcessor()
        failed = LoginFailedTrackingProcessor()
    }
}

final class LoginAttemptedTrackingProcessor: EventProcessor<LoginEvents.Attempted> {
    @Resolved private var analytics: AnalyticsServiceProtocol
    override func handle(_ event: LoginEvents.Attempted) {
        analytics.track(.loginAttempt(email: event.email))
    }
}

final class LoginSucceededTrackingProcessor: EventProcessor<LoginEvents.Succeeded> {
    @Resolved private var analytics: AnalyticsServiceProtocol
    override func handle(_ event: LoginEvents.Succeeded) {
        analytics.track(.loginSuccess(userId: event.userId))
    }
}

final class LoginFailedTrackingProcessor: EventProcessor<LoginEvents.Failed> {
    @Resolved private var analytics: AnalyticsServiceProtocol
    override func handle(_ event: LoginEvents.Failed) {
        analytics.track(.loginFailure(reason: event.reason))
    }
}
