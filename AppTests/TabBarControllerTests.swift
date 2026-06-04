import XCTest
import UIKit
import TPAUnitTestFoundation
@testable import ThePandaApp

final class TabBarControllerTests: AppTestCase {

    private func makeTabBar() -> AppTabBarController {
        AppTabBarController(discoveryNav: UINavigationController(),
                            profileNav: UINavigationController())
    }

    func test_tabBar_hasTwoTabs() {
        let tabBar = makeTabBar()
        tabBar.loadViewIfNeeded()
        XCTAssertEqual(tabBar.viewControllers?.count, 2)
    }

    func test_tabBar_firstTab_isDiscoveryNav() {
        let discovery = UINavigationController()
        let tabBar = AppTabBarController(discoveryNav: discovery, profileNav: UINavigationController())
        XCTAssertTrue(tabBar.viewControllers?.first === discovery)
    }

    func test_tabBar_secondTab_isProfileNav() {
        let profile = UINavigationController()
        let tabBar = AppTabBarController(discoveryNav: UINavigationController(), profileNav: profile)
        XCTAssertTrue(tabBar.viewControllers?.last === profile)
    }

    func test_tabBar_discoveryItem_hasCorrectAccessibilityId() {
        let tabBar = makeTabBar()
        XCTAssertEqual(tabBar.viewControllers?.first?.tabBarItem.accessibilityIdentifier, "discovery-tab")
    }

    func test_tabBar_profileItem_hasCorrectAccessibilityId() {
        let tabBar = makeTabBar()
        XCTAssertEqual(tabBar.viewControllers?.last?.tabBarItem.accessibilityIdentifier, "profile-tab")
    }
}
