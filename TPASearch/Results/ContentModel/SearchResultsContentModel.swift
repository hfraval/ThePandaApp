import Foundation

public enum SearchResultsContentModel: Equatable {
    case loading
    case empty
    case results([SearchResultItem])
    case failed
}
