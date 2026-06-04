import Foundation

public enum SearchError: Error, Equatable, Sendable {
    case network
    case decoding
    case unknown
}

public protocol SearchServiceProtocol: Sendable {
    func search(_ query: SearchQuery) async -> Result<[SearchResultItem], SearchError>
}
