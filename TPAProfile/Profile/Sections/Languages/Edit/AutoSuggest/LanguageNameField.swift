import UIKit
import TPAUIKit
import TPAFoundation

@MainActor
protocol LanguageNameFieldDelegate: AnyObject {
    func languageNameField(_ field: LanguageNameField, present viewController: UIViewController)
    func languageNameFieldSelectionChanged(_ field: LanguageNameField)
}

final class LanguageNameField: FormTextField, UITextFieldDelegate {

    weak var delegate: LanguageNameFieldDelegate?
    private(set) var selection: LanguageNameSuggestion?

    init() {
        super.init(
            title: localize("profile.languages.edit.nameLabel"),
            placeholder: localize("profile.languages.edit.namePlaceholder")
        )
        textField.delegate = self
        textField.accessibilityIdentifier = "language-name-field"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setSelection(_ selection: LanguageNameSuggestion?) {
        self.selection = selection
        textField.text = selection?.text
        delegate?.languageNameFieldSelectionChanged(self)
    }

    var isValid: Bool { selection != nil }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let autoSuggest = LanguageNameAutoSuggestViewController(initialText: selection?.text) { [weak self] suggestion in
            self?.setSelection(suggestion)
        }
        delegate?.languageNameField(self, present: UINavigationController(rootViewController: autoSuggest))
        return false
    }
}
