import Foundation
import TPANetwork

enum DummyJSONEndpoint {
    static let base = URL(string: "https://dummyjson.com")!

    static func products(for query: SearchQuery) -> Endpoint {
        var serverQuery: [String: String] = [
            "limit": "\(query.limit)",
            "skip": "\(query.skip)",
            "order": query.order.rawValue
        ]
        if let sortBy = query.sortBy {
            serverQuery["sortBy"] = sortBy.rawValue
        }

        let trimmedText = query.text.trimmingCharacters(in: .whitespacesAndNewlines)

        if let category = query.category, !category.isEmpty {
            return Endpoint(base: base, path: "/products/category/\(category)", query: serverQuery)
        } else if !trimmedText.isEmpty {
            serverQuery["q"] = trimmedText
            return Endpoint(base: base, path: "/products/search", query: serverQuery)
        } else {
            return Endpoint(base: base, path: "/products", query: serverQuery)
        }
    }

    static func categoryList() -> Endpoint {
        Endpoint(base: base, path: "/products/category-list")
    }
}

private extension Endpoint {
    init(base: URL, path: String, query: [String: String] = [:]) {
        self.init(baseURL: base, path: path, method: .get, query: query)
    }
}
