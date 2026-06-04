struct SortByFilterViewModel: Equatable {
    let selectedIndex: Int

    init(query: SearchQuery) {
        switch query.sortBy {
        case nil: selectedIndex = 0
        case .title?: selectedIndex = 1
        case .price?: selectedIndex = 2
        case .rating?: selectedIndex = 3
        }
    }
}
