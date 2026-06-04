struct InStockFilterViewModel: Equatable {
    let isOn: Bool

    init(query: SearchQuery) {
        isOn = query.inStockOnly
    }
}
