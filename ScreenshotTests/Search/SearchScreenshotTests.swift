import XCTest
import TPAFoundation
import TPAUnitTestFoundation
@testable import TPASearch

@MainActor
final class SearchScreenshotTests: ScreenshotTestCase {
    override func setUp() async throws {
        try await super.setUp()
        ServiceContainer.shared.registerInstance(MockSearchService() as SearchServiceProtocol, as: SearchServiceProtocol.self)
    }

    func test_searchResults() {
        assertAppearance { SearchResultsViewController(query: SearchQuery(text: "phone")) }
    }

    func test_searchEmpty() {
        assertAppearance { SearchResultsViewController(query: SearchQuery(text: "")) }
    }
}
