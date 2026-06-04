import TPAFoundation

struct PriceFilterViewModel: Equatable {
    let value: Float
    let displayText: String

    init(query: SearchQuery) {
        let price = Float(query.maxPrice ?? 0)
        value = price
        displayText = PriceFilterViewModel.label(for: price)
    }

    static func label(for value: Float) -> String {
        value <= 0 ? localize("search.filters.brand.any") : "$\(Int(value))"
    }
}
