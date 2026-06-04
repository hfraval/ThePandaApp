import XCTest

struct ProfileScreenElement {
    private var app: XCUIApplication { XCUIApplication() }

    var nameLabel: XCUIElement { app.staticTexts["profile-name-label"] }
    var settingsButton: XCUIElement { app.buttons["settings-button"] }
    var personalDetailsHeader: XCUIElement { app.otherElements["profile-personal-details"] }

    var isVisible: Bool { nameLabel.waitToExist() }
}
