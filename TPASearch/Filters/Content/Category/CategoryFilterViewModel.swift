struct CategoryFilterViewModel: Equatable {
    let category: String

    init(query: SearchQuery) {
        category = query.category ?? ""
    }
}
