import Foundation
import TPAFoundation

struct SearchBarViewModelFactory {
    func make() -> SearchBarViewModel {
        SearchBarViewModel(
            prompt: localize("discovery.search.prompt"),
            keywordsPlaceholder: localize("search.keywords.placeholder"),
            searchButtonTitle: localize("search.button.title")
        )
    }
}
