import XCTest

class AppUITestCase: XCTestCase, Steps {
    private(set) var app: XCUIApplication!

    enum Scenario {
        case mockSearch

        var launchArguments: [String] {
            switch self {
            case .mockSearch: return ["-uiTestMockSearch"]
            }
        }
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func launch(_ scenarios: Scenario...) {
        app = XCUIApplication()
        app.launchArguments += ["-uiTestReset"]
        app.launchArguments += scenarios.flatMap(\.launchArguments)
        app.launch()
    }
}
