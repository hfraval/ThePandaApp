import XCTest
import TPACore
import TPAAnalytics
import TPAUnitTestFoundation
@testable import ThePandaApp

@MainActor
final class AppLifecycleTests: AppTestCase {
    @MockResolved<AppLifecycleServiceProtocol, MockAppLifecycleService> var _lifecycle
    @MockResolved<AnalyticsServiceProtocol, MockAnalyticsService> var _analytics

    func test_coldStart_invokesLifecycleService() {
        let service = MockAppLifecycleService()
        service.applicationDidFinishLaunching()
        XCTAssertEqual(service.launchCallCount, 1)
    }

    func test_warmStart_invokesLifecycleService() {
        let service = MockAppLifecycleService()
        service.applicationWillEnterForeground()
        XCTAssertEqual(service.foregroundCallCount, 1)
    }

    func test_bootStrapper_coldStart_tracksAnalytics() {
        let bootStrapper = AppBootStrapper()
        bootStrapper.startCritical()
        XCTAssertTrue(_analytics.hasTracked("app_cold_start"))
    }

    func test_bootStrapper_warmStart_tracksAnalytics() {
        let bootStrapper = AppBootStrapper()
        bootStrapper.handleWarmStart()
        XCTAssertTrue(_analytics.hasTracked("app_warm_start"))
    }
}
