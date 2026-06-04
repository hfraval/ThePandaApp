import Foundation

public struct SearchResultItem: Equatable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let detail: String
    public let imageURL: URL?

    public let price: Double
    public let rating: Double
    public let inStock: Bool
    public let brand: String?
    public let category: String

    public init(
        id: String,
        title: String,
        subtitle: String,
        detail: String,
        imageURL: URL?,
        price: Double,
        rating: Double,
        inStock: Bool,
        brand: String?,
        category: String
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.detail = detail
        self.imageURL = imageURL
        self.price = price
        self.rating = rating
        self.inStock = inStock
        self.brand = brand
        self.category = category
    }
}
