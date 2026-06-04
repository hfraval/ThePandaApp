import XCTest
import TPAFoundation
import TPAUnitTestFoundation

open class ScreenshotTestCase: AppTestCase {
    open override func setUp() async throws {
        try await super.setUp()
        UIView.setAnimationsEnabled(false)
        ServiceContainer.shared.registerInstance(
            LocalizedStringsService() as LocalizedStringsServiceProtocol,
            as: LocalizedStringsServiceProtocol.self
        )
    }

    open override func tearDown() async throws {
        UIView.setAnimationsEnabled(true)
        try await super.tearDown()
    }
}
