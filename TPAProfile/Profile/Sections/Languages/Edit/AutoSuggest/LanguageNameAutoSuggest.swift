import Foundation
import TPAFoundation
import TPAUIKit

enum LanguageNameAutoSuggestEvents {
    struct ValueChanged: Event, Equatable {
        let text: String?
        init(text: String?) { self.text = text }
    }
}

public enum SuggestedLanguageNamesViewModel: Equatable {
    case loading
    case suggestions([LanguageNameSuggestion])
}

@MainActor
protocol SuggestedLanguageNamesViewModelProviderProtocol: AnyObject {
    var delegate: AnyViewModelProviderDelegate<SuggestedLanguageNamesViewModel>? { get set }
}

@MainActor
final class SuggestedLanguageNamesViewModelProvider: SuggestedLanguageNamesViewModelProviderProtocol {
    @Resolved private var service: SuggestedLanguageNamesServiceProtocol

    weak var delegate: AnyViewModelProviderDelegate<SuggestedLanguageNamesViewModel>?

    init() {
        observe(self, event: LanguageNameAutoSuggestEvents.ValueChanged.self, selector: #selector(valueChanged(_:)))
    }

    @objc private func valueChanged(_ note: Notification) {
        let text = (note.eventPayload() as LanguageNameAutoSuggestEvents.ValueChanged?)?.text ?? ""
        delegate?.viewModelUpdated(.loading)
        Task { [weak self] in
            guard let self else { return }
            let suggestions = await self.service.suggestions(for: text)
            self.delegate?.viewModelUpdated(.suggestions(suggestions))
        }
    }
}
