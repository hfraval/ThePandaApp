import Foundation
import TPANetwork

public final class DummyJSONSearchService: SearchServiceProtocol {
    private let httpClient: HTTPClientProtocol
    private let applyClientFilters = ApplyClientFiltersCommand()
    private let priceFormatter: NumberFormatter

    public init(httpClient: HTTPClientProtocol) {
        self.httpClient = httpClient
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        self.priceFormatter = formatter
    }

    public func search(_ query: SearchQuery) async -> Result<[SearchResultItem], SearchError> {
        let endpoint = DummyJSONEndpoint.products(for: query)
        let result: Result<ProductListResponse, NetworkError> = await httpClient.send(endpoint)

        switch result {
        case .success(let response):
            let items = response.products.map(map)
            return .success(applyClientFilters(items, query: query))
        case .failure(let error):
            return .failure(Self.map(error))
        }
    }

    private static func map(_ error: NetworkError) -> SearchError {
        switch error {
        case .decodingFailed: return .decoding
        case .timeout, .notConnected, .serverError, .invalidURL, .noData: return .network
        case .cancelled, .unknown: return .unknown
        }
    }

    private func map(_ dto: ProductDTO) -> SearchResultItem {
        SearchResultItem(
            id: "\(dto.id)",
            title: dto.title,
            subtitle: dto.brand ?? dto.category.capitalized,
            detail: priceFormatter.string(from: NSNumber(value: dto.price)) ?? "$\(dto.price)",
            imageURL: URL(string: dto.thumbnail),
            price: dto.price,
            rating: dto.rating,
            inStock: dto.stock > 0,
            brand: dto.brand,
            category: dto.category
        )
    }
}
