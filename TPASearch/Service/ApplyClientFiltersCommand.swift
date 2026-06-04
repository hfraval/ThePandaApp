import Foundation

struct ApplyClientFiltersCommand {
    func callAsFunction(_ items: [SearchResultItem], query: SearchQuery) -> [SearchResultItem] {
        items.filter { item in
            if let maxPrice = query.maxPrice, item.price > maxPrice { return false }
            if let minRating = query.minimumRating, item.rating < minRating { return false }
            if query.inStockOnly, !item.inStock { return false }
            if let brand = query.brand, item.brand != brand { return false }
            return true
        }
    }
}
