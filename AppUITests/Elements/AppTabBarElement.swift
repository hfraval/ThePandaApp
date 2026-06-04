import XCTest

struct AppTabBarElement {
    private var app: XCUIApplication { XCUIApplication() }

    var discoveryTab: XCUIElement { app.tabBars.buttons.element(boundBy: 0) }
    var profileTab: XCUIElement { app.tabBars.buttons.element(boundBy: 1) }

    @discardableResult
    func openDiscovery() -> AppTabBarElement { discoveryTab.tapWhenReady(); return self }

    @discardableResult
    func openProfile() -> AppTabBarElement { profileTab.tapWhenReady(); return self }
}
