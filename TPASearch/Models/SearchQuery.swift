import Foundation

public struct SearchQuery: Equatable, Sendable {
    public enum SortField: String, Sendable, CaseIterable {
        case title, price, rating
    }
    public enum SortOrder: String, Sendable {
        case asc, desc
    }

    public var text: String
    public var category: String?
    public var sortBy: SortField?
    public var order: SortOrder
    public var maxPrice: Double?
    public var minimumRating: Double?
    public var inStockOnly: Bool
    public var brand: String?
    public var limit: Int
    public var skip: Int

    public init(
        text: String = "",
        category: String? = nil,
        sortBy: SortField? = nil,
        order: SortOrder = .asc,
        maxPrice: Double? = nil,
        minimumRating: Double? = nil,
        inStockOnly: Bool = false,
        brand: String? = nil,
        limit: Int = 30,
        skip: Int = 0
    ) {
        self.text = text
        self.category = category
        self.sortBy = sortBy
        self.order = order
        self.maxPrice = maxPrice
        self.minimumRating = minimumRating
        self.inStockOnly = inStockOnly
        self.brand = brand
        self.limit = limit
        self.skip = skip
    }

    public var hasClientFilters: Bool {
        maxPrice != nil || minimumRating != nil || inStockOnly || brand != nil
    }
}
