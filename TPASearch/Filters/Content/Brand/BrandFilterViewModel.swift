struct BrandFilterViewModel: Equatable {
    let brand: String

    init(query: SearchQuery) {
        brand = query.brand ?? ""
    }
}
