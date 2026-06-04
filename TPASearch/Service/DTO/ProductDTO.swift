import Foundation

struct ProductListResponse: Decodable, Equatable {
    let products: [ProductDTO]
    let total: Int
    let skip: Int
    let limit: Int
}

struct ProductDTO: Decodable, Equatable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let rating: Double
    let stock: Int
    let brand: String?
    let thumbnail: String
}
