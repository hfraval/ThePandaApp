import Foundation

public protocol AppLifecycleServiceProtocol: Sendable {
    func applicationDidFinishLaunching()
    func applicationWillEnterForeground()
    func applicationDidBecomeActive()
    func applicationWillResignActive()
    func applicationDidEnterBackground()
}
