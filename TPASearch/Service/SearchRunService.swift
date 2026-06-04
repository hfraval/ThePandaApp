import Foundation
import TPAFoundation

@MainActor
protocol SearchRunServiceProtocol {
    func run(_ query: SearchQuery) async
}

@MainActor
final class SearchRunService: SearchRunServiceProtocol {
    @Resolved private var searchService: SearchServiceProtocol

    func run(_ query: SearchQuery) async {
        post(SearchEvents.Searched(keywords: query.text))
        post(SearchEvents.Submitting())

        switch await searchService.search(query) {
        case .success(let items):
            post(SearchEvents.Loaded(items: items))
        case .failure:
            post(SearchEvents.Failed())
        }
    }
}
