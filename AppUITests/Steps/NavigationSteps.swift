import XCTest

protocol NavigationSteps: Steps {}

extension NavigationSteps where Self: XCTestCase {
    func Open_The_Discovery_Tab() {
        tabBar.openDiscovery()
    }

    func Open_The_Profile_Tab() {
        tabBar.openProfile()
    }
}
