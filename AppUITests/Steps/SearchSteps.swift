import XCTest

protocol SearchSteps: Steps {}

extension SearchSteps where Self: XCTestCase {
    func The_Search_Bar_Is_Shown() {
        XCTAssertTrue(discoveryScreen.isSearchBarVisible, "expected the search bar")
        XCTAssertTrue(discoveryScreen.searchButton.exists)
    }

    func The_Under_Construction_Text_Is_Shown() {
        XCTAssertTrue(discoveryScreen.underConstructionText.waitToExist(timeout: 3))
    }

    func I_Search_For(_ text: String) {
        discoveryScreen.search(text)
    }

    func The_Search_Results_Are_Shown() {
        XCTAssertTrue(searchResults.isVisible, "expected the results table")
        XCTAssertTrue(searchResults.firstCell.waitToExist(), "expected at least one result")
    }

    func The_Filters_Button_Is_Shown() {
        XCTAssertTrue(searchResults.filtersButton.waitToExist())
    }

    func I_Tap_The_First_Result() {
        searchResults.firstCell.tap()
    }

    func I_Am_Still_On_The_Results() {
        XCTAssertTrue(searchResults.table.exists, "result rows must not navigate away")
    }
}
