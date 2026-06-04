import XCTest

final class SearchUITests: AppUITestCase, NavigationSteps, SearchSteps {

    func test_discoveryTab_showsSearchBar() {
        launch(.mockSearch)
        Given.Open_The_Discovery_Tab()
        Then.The_Search_Bar_Is_Shown()
    }

    func test_search_pushesResults() {
        launch(.mockSearch)
        Given.Open_The_Discovery_Tab()
        And.The_Search_Bar_Is_Shown()
        When.I_Search_For("iOS")
        Then.The_Search_Results_Are_Shown()
        When.I_Tap_The_First_Result()
        Then.I_Am_Still_On_The_Results()
    }

    func test_results_showFiltersButton() {
        launch(.mockSearch)
        Given.Open_The_Discovery_Tab()
        When.I_Search_For("phone")
        Then.The_Filters_Button_Is_Shown()
    }
}
