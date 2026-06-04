import XCTest

struct DiscoveryScreenElement {
    private var app: XCUIApplication { XCUIApplication() }

    var keywordsField: XCUIElement { app.textFields["search-keywords-field"] }
    var searchButton: XCUIElement { app.buttons["search-button"] }
    var underConstructionText: XCUIElement { app.staticTexts["Under Construction"] }

    var isSearchBarVisible: Bool { keywordsField.waitToExist() }

    func search(_ text: String) {
        keywordsField.type(text)
        searchButton.tapWhenReady()
    }
}
