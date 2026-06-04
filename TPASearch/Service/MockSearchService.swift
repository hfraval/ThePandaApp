import Foundation

public final class MockSearchService: SearchServiceProtocol {
    private let applyClientFilters = ApplyClientFiltersCommand()

    public init() {}

    public func search(_ query: SearchQuery) async -> Result<[SearchResultItem], SearchError> {
        let text = query.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty || query.category != nil else { return .success([]) }

        let label = query.category?.capitalized ?? text
        let brands = ["Bamboo", "Eucalyptus", "Outback", "Marsupial", "Canopy"]
        let category = query.category ?? "general"

        var items: [SearchResultItem] = []
        for index in 0..<brands.count {
            let price = Double(index * 25 + 19)
            let rating = 3.0 + Double(index) * 0.4
            items.append(
                SearchResultItem(
                    id: "mock-\(index)",
                    title: "\(label) item \(index + 1)",
                    subtitle: brands[index],
                    detail: "$\(price)",
                    imageURL: nil,
                    price: price,
                    rating: rating,
                    inStock: index % 4 != 0,
                    brand: brands[index],
                    category: category
                )
            )
        }
        return .success(applyClientFilters(items, query: query))
    }
}
