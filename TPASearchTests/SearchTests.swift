import XCTest
import TPAFoundation
import TPAUIKit
import TPANetwork
import TPAUnitTestFoundation
@testable import TPASearch

@MainActor
private final class CaptureContentDelegate: ContentModelProviderDelegate {
    var latest: SearchResultsContentModel?
    func contentModelUpdated(_ contentModel: SearchResultsContentModel) { latest = contentModel }
}

private func item(
    id: String = "1", title: String = "t", price: Double = 10, rating: Double = 5,
    inStock: Bool = true, brand: String? = "Acme"
) -> SearchResultItem {
    SearchResultItem(id: id, title: title, subtitle: brand ?? "", detail: "$\(price)",
                     imageURL: nil, price: price, rating: rating, inStock: inStock,
                     brand: brand, category: "general")
}

@MainActor
final class MockSearchServiceTests: AppTestCase {
    func test_emptyQuery_returnsNoResults() async {
        let items = await MockSearchService().search(SearchQuery(text: "  ")).items
        XCTAssertTrue(items.isEmpty)
    }

    func test_textQuery_returnsResults() async {
        let items = await MockSearchService().search(SearchQuery(text: "phone")).items
        XCTAssertFalse(items.isEmpty)
        XCTAssertTrue(items.contains { $0.title.contains("phone") })
    }

    func test_inStockFilter_removesOutOfStock() async {
        let all = await MockSearchService().search(SearchQuery(text: "phone")).items
        let inStock = await MockSearchService().search(SearchQuery(text: "phone", inStockOnly: true)).items
        XCTAssertLessThan(inStock.count, all.count)
        XCTAssertTrue(inStock.allSatisfy { $0.inStock })
    }
}

private extension Result where Success == [SearchResultItem] {
    var items: [SearchResultItem] { (try? get()) ?? [] }
}

@MainActor
final class ApplyClientFiltersCommandTests: AppTestCase {
    private let apply = ApplyClientFiltersCommand()

    func test_maxPrice() {
        let items = [item(id: "a", price: 5), item(id: "b", price: 50)]
        let result = apply(items, query: SearchQuery(maxPrice: 10))
        XCTAssertEqual(result.map(\.id), ["a"])
    }

    func test_minimumRating() {
        let items = [item(id: "a", rating: 2), item(id: "b", rating: 4.5)]
        let result = apply(items, query: SearchQuery(minimumRating: 4))
        XCTAssertEqual(result.map(\.id), ["b"])
    }

    func test_brand() {
        let items = [item(id: "a", brand: "Acme"), item(id: "b", brand: "Other")]
        let result = apply(items, query: SearchQuery(brand: "Other"))
        XCTAssertEqual(result.map(\.id), ["b"])
    }

    func test_inStockOnly() {
        let items = [item(id: "a", inStock: false), item(id: "b", inStock: true)]
        let result = apply(items, query: SearchQuery(inStockOnly: true))
        XCTAssertEqual(result.map(\.id), ["b"])
    }
}

@MainActor
final class DummyJSONSearchServiceTests: AppTestCase {
    func test_search_mapsProductsToItems() async {
        let json = """
        {"products":[
          {"id":1,"title":"iPhone","description":"d","category":"smartphones","price":999.0,"rating":4.7,"stock":5,"brand":"Apple","thumbnail":"https://img/x.jpg"}
        ],"total":1,"skip":0,"limit":30}
        """
        let client = MockHTTPClient()
        client.dataResult = .success(Data(json.utf8))

        let items = await DummyJSONSearchService(httpClient: client).search(SearchQuery(text: "iphone")).items

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.title, "iPhone")
        XCTAssertEqual(items.first?.subtitle, "Apple")
        XCTAssertEqual(items.first?.imageURL?.absoluteString, "https://img/x.jpg")
        XCTAssertTrue(items.first?.inStock == true)
    }

    func test_search_appliesClientFilter() async {
        let json = """
        {"products":[
          {"id":1,"title":"Cheap","description":"d","category":"c","price":5.0,"rating":4.0,"stock":1,"brand":"A","thumbnail":"u"},
          {"id":2,"title":"Pricey","description":"d","category":"c","price":500.0,"rating":4.0,"stock":1,"brand":"A","thumbnail":"u"}
        ],"total":2,"skip":0,"limit":30}
        """
        let client = MockHTTPClient()
        client.dataResult = .success(Data(json.utf8))

        let items = await DummyJSONSearchService(httpClient: client).search(SearchQuery(text: "x", maxPrice: 10)).items

        XCTAssertEqual(items.map(\.title), ["Cheap"])
    }

    func test_search_networkFailure_returnsError() async {
        let client = MockHTTPClient()
        client.dataResult = .failure(.timeout)
        let result = await DummyJSONSearchService(httpClient: client).search(SearchQuery(text: "x"))
        XCTAssertEqual(result, .failure(.network))
    }
}

@MainActor
final class DummyJSONEndpointTests: AppTestCase {
    func test_textQuery_usesSearchEndpoint() {
        let ep = DummyJSONEndpoint.products(for: SearchQuery(text: "phone"))
        XCTAssertEqual(ep.path, "/products/search")
        XCTAssertEqual(ep.query["q"], "phone")
    }

    func test_category_usesCategoryEndpoint() {
        let ep = DummyJSONEndpoint.products(for: SearchQuery(category: "smartphones"))
        XCTAssertEqual(ep.path, "/products/category/smartphones")
    }

    func test_sort_addsParams() {
        let ep = DummyJSONEndpoint.products(for: SearchQuery(text: "x", sortBy: .price, order: .desc))
        XCTAssertEqual(ep.query["sortBy"], "price")
        XCTAssertEqual(ep.query["order"], "desc")
    }
}

@MainActor
final class SearchResultsContentModelProviderTests: AppTestCase {
    private var provider: SearchResultsContentModelProvider!
    private var capture: CaptureContentDelegate!
    private var anyDelegate: AnyContentModelProviderDelegate<SearchResultsContentModel>!

    override func setUp() async throws {
        try await super.setUp()
        provider = SearchResultsContentModelProvider()
        capture = CaptureContentDelegate()
        anyDelegate = AnyContentModelProviderDelegate(capture)
        provider.delegate = anyDelegate
    }

    override func tearDown() async throws {
        provider = nil; capture = nil; anyDelegate = nil
        try await super.tearDown()
    }

    func test_initial_isLoading() {
        XCTAssertEqual(capture.latest, .loading)
    }

    func test_submitting_isLoading() {
        post(SearchEvents.Loaded(items: [item()]))
        post(SearchEvents.Submitting())
        XCTAssertEqual(capture.latest, .loading)
    }

    func test_loadedWithItems_isResults() {
        let items = [item()]
        post(SearchEvents.Loaded(items: items))
        XCTAssertEqual(capture.latest, .results(items))
    }

    func test_loadedEmpty_isEmpty() {
        post(SearchEvents.Loaded(items: []))
        XCTAssertEqual(capture.latest, .empty)
    }

    func test_failedEvent_isFailed() {
        post(SearchEvents.Failed())
        XCTAssertEqual(capture.latest, .failed)
    }
}

@MainActor
final class SearchRunServiceFailureTests: AppTestCase {
    private final class FailingSearchService: SearchServiceProtocol {
        func search(_ query: SearchQuery) async -> Result<[SearchResultItem], SearchError> {
            .failure(.network)
        }
    }

    func test_run_failure_postsFailedEvent() async {
        ServiceContainer.shared.registerInstance(FailingSearchService() as SearchServiceProtocol, as: SearchServiceProtocol.self)
        let center = ServiceContainer.shared.resolve(NotificationCenter.self)
        var failed = false
        let token = center.addObserver(forName: SearchEvents.Failed.notificationName, object: nil, queue: nil) { _ in failed = true }
        defer { center.removeObserver(token) }

        await SearchRunService().run(SearchQuery(text: "x"))

        XCTAssertTrue(failed)
    }
}
