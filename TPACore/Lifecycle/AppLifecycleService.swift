import Foundation
import TPALogging

public final class AppLifecycleService: AppLifecycleServiceProtocol, @unchecked Sendable {
    private let logger: LoggerProtocol
    private var launchDate: Date?

    public init(logger: LoggerProtocol) {
        self.logger = logger
    }

    public func applicationDidFinishLaunching() {
        launchDate = Date()
        logger.info("🚀 App launched — Cold Start")
    }

    public func applicationWillEnterForeground() {
        logger.info("♻️ App entering foreground — Warm Start")
    }

    public func applicationDidBecomeActive() {
        logger.info("✅ App became active")
    }

    public func applicationWillResignActive() {
        logger.info("⏸ App will resign active")
    }

    public func applicationDidEnterBackground() {
        logger.info("💤 App entered background")
    }
}
