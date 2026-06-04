import XCTest

struct SearchResultsScreenElement {
    private var app: XCUIApplication { XCUIApplication() }

    var table: XCUIElement { app.tables["search-results-table"] }
    var firstCell: XCUIElement { table.cells.firstMatch }
    var filtersButton: XCUIElement { app.buttons["search-filters-button"] }

    var isVisible: Bool { table.waitToExist() }
}
