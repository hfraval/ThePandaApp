import Foundation
import TPACore

public final class MockAppLifecycleService: AppLifecycleServiceProtocol, @unchecked Sendable {
    public private(set) var launchCallCount = 0
    public private(set) var foregroundCallCount = 0
    public private(set) var activeCallCount = 0
    public private(set) var resignCallCount = 0
    public private(set) var backgroundCallCount = 0

    public init() {}

    public func applicationDidFinishLaunching() { launchCallCount += 1 }
    public func applicationWillEnterForeground() { foregroundCallCount += 1 }
    public func applicationDidBecomeActive() { activeCallCount += 1 }
    public func applicationWillResignActive() { resignCallCount += 1 }
    public func applicationDidEnterBackground() { backgroundCallCount += 1 }
}
