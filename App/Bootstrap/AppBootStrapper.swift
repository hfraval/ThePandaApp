import Foundation
import TPAFoundation
import TPACore
import TPAAnalytics

@MainActor
final class AppBootStrapper {
    @Resolved private var lifecycleService: AppLifecycleServiceProtocol
    @Resolved private var analytics: AnalyticsServiceProtocol

    private var processors: AppProcessors?

    func startCritical() {
        processors = AppProcessors()
        lifecycleService.applicationDidFinishLaunching()
        analytics.track(.appColdStart())
    }

    func startDeferred() {
    }

    func handleWarmStart() {
        lifecycleService.applicationWillEnterForeground()
        analytics.track(.appWarmStart())
    }
}
