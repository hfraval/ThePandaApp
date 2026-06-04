import XCTest
import TPAFoundation

@MainActor
open class TestCase: XCTestCase {
    open override func setUp() async throws {
        try await super.setUp()
        ServiceContainer.shared.reset()
    }

    open override func tearDown() async throws {
        ServiceContainer.shared.reset()
        try await super.tearDown()
    }
}
