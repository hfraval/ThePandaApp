import XCTest

extension XCUIElement {
    @discardableResult
    func waitToExist(timeout: TimeInterval = 5) -> Bool {
        waitForExistence(timeout: timeout)
    }

    func tapWhenReady(timeout: TimeInterval = 5) {
        _ = waitForExistence(timeout: timeout)
        tap()
    }

    func type(_ text: String, timeout: TimeInterval = 5) {
        tapWhenReady(timeout: timeout)
        typeText(text)
    }
}
