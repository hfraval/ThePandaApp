import TPAFoundation
import TPALogging

public final class UnauthorizedPolicyProcessor: EventProcessor<AuthEvents.Unauthorized> {
    @Resolved private var logger: LoggerProtocol

    public override func handle(_ event: AuthEvents.Unauthorized) {
        logger.warning(
            "401 on an authenticated request. (mock auth) Not signing out — implement refresh/sign-out here when real auth lands."
        )
    }
}
