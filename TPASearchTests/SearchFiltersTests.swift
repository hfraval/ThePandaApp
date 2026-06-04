import XCTest
import TPAFoundation
import TPAUIKit
import TPAUnitTestFoundation
@testable import TPASearch

@MainActor
final class SearchFiltersContentModelProviderTests: AppTestCase {

    func test_inStockEvent_updatesDraftQuery_preservingOtherFields() async {
        let provider = SearchFiltersContentModelProvider(query: SearchQuery(text: "phone"))

        post(SearchFilterEvents.InStockDidUpdate(inStockOnly: true))
        await drain()

        XCTAssertTrue(provider.query.inStockOnly)
        XCTAssertEqual(provider.query.text, "phone")
    }

    func test_eachFilterEvent_writesItsValue() async {
        let provider = SearchFiltersContentModelProvider(query: SearchQuery())

        post(SearchFilterEvents.CategoryDidUpdate(category: "phones"))
        post(SearchFilterEvents.SortByDidUpdate(sortBy: .price))
        post(SearchFilterEvents.PriceDidUpdate(maxPrice: 500))
        post(SearchFilterEvents.RatingDidUpdate(minimumRating: 4))
        post(SearchFilterEvents.BrandDidUpdate(brand: "Acme"))
        await drain()

        XCTAssertEqual(provider.query.category, "phones")
        XCTAssertEqual(provider.query.sortBy, .price)
        XCTAssertEqual(provider.query.maxPrice, 500)
        XCTAssertEqual(provider.query.minimumRating, 4)
        XCTAssertEqual(provider.query.brand, "Acme")
    }

    func test_provider_pushesUpdatedModelToDelegate() async {
        let provider = SearchFiltersContentModelProvider(query: SearchQuery())
        let capture = CaptureDelegate()
        let anyDelegate = AnyContentModelProviderDelegate<SearchFiltersContentModel>(capture)
        provider.delegate = anyDelegate

        post(SearchFilterEvents.InStockDidUpdate(inStockOnly: true))
        await drain()

        XCTAssertEqual(capture.latest?.query.inStockOnly, true)
    }

    private func drain() async {
        await Task.yield()
        try? await Task.sleep(nanoseconds: 50_000_000)
    }
}

@MainActor
private final class CaptureDelegate: ContentModelProviderDelegate {
    var latest: SearchFiltersContentModel?
    func contentModelUpdated(_ contentModel: SearchFiltersContentModel) { latest = contentModel }
}
