import TPAFoundation

struct RatingFilterViewModel: Equatable {
    let value: Double
    let displayText: String

    init(query: SearchQuery) {
        let rating = query.minimumRating ?? 0
        value = rating
        displayText = RatingFilterViewModel.label(for: rating)
    }

    static func label(for value: Double) -> String {
        value <= 0 ? localize("search.filters.brand.any") : "★ \(Int(value))+"
    }
}
