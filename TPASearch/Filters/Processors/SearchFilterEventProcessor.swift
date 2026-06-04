import Foundation
import TPAFoundation

class SearchFilterEventProcessor<E: Event>: EventProcessor<E> {
    private weak var provider: SearchFiltersContentModelProvider?

    init(_ provider: SearchFiltersContentModelProvider) {
        self.provider = provider
        super.init()
    }

    override func handle(_ event: E) {
        Task { @MainActor [weak provider] in
            guard let provider else { return }
            var query = provider.query
            self.update(&query, for: event)
            provider.query = query
        }
    }

    func update(_ query: inout SearchQuery, for event: E) {
        fatalError("SearchFilterEventProcessor subclasses must override update(_:for:)")
    }
}
