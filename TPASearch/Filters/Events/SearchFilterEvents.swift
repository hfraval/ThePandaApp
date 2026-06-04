import TPAFoundation

enum SearchFilterEvents {
    struct CategoryDidUpdate: Event, Equatable { let category: String? }
    struct SortByDidUpdate: Event, Equatable { let sortBy: SearchQuery.SortField? }
    struct PriceDidUpdate: Event, Equatable { let maxPrice: Double? }
    struct RatingDidUpdate: Event, Equatable { let minimumRating: Double? }
    struct InStockDidUpdate: Event, Equatable { let inStockOnly: Bool }
    struct BrandDidUpdate: Event, Equatable { let brand: String? }
}
