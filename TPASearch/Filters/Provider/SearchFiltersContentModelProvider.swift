import Foundation
import TPAFoundation
import TPAUIKit

@MainActor
protocol SearchFiltersContentModelProviderProtocol: AnyObject {
    var query: SearchQuery { get set }
    var delegate: AnyContentModelProviderDelegate<SearchFiltersContentModel>? { get set }
}

@MainActor
final class SearchFiltersContentModelProvider: SearchFiltersContentModelProviderProtocol {
    private(set) var processors: [Processor] = []

    private var contentModel: SearchFiltersContentModel {
        didSet { delegate?.contentModelUpdated(contentModel) }
    }

    weak var delegate: AnyContentModelProviderDelegate<SearchFiltersContentModel>? {
        didSet { delegate?.contentModelUpdated(contentModel) }
    }

    var query: SearchQuery {
        get { contentModel.query }
        set { contentModel = SearchFiltersContentModel(query: newValue) }
    }

    init(query: SearchQuery) {
        contentModel = SearchFiltersContentModel(query: query)
        processors = [
            UpdateCategoryProcessor(self),
            UpdateSortByProcessor(self),
            UpdatePriceProcessor(self),
            UpdateRatingProcessor(self),
            UpdateInStockProcessor(self),
            UpdateBrandProcessor(self)
        ]
    }
}
