import Foundation
import TPAFoundation
import TPAUIKit

@MainActor
protocol SearchResultsContentModelProviderProtocol: AnyObject {
    var delegate: AnyContentModelProviderDelegate<SearchResultsContentModel>? { get set }
}

@MainActor
final class SearchResultsContentModelProvider: SearchResultsContentModelProviderProtocol {
    private var contentModel: SearchResultsContentModel = .loading {
        didSet { delegate?.contentModelUpdated(contentModel) }
    }

    weak var delegate: AnyContentModelProviderDelegate<SearchResultsContentModel>? {
        didSet { delegate?.contentModelUpdated(contentModel) }
    }

    init() {
        observe(self, event: SearchEvents.Submitting.self, selector: #selector(handleSubmitting))
        observe(self, event: SearchEvents.Loaded.self, selector: #selector(handleLoaded(_:)))
        observe(self, event: SearchEvents.Failed.self, selector: #selector(handleFailed))
    }

    @objc private func handleSubmitting() {
        contentModel = .loading
    }

    @objc private func handleLoaded(_ note: Notification) {
        let items = (note.eventPayload() as SearchEvents.Loaded?)?.items ?? []
        contentModel = items.isEmpty ? .empty : .results(items)
    }

    @objc private func handleFailed() {
        contentModel = .failed
    }
}
