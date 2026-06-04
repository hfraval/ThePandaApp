import UIKit
import TPACore
import TPAUIKit
import TPAFoundation

final class EditProfileLanguageView: Form {

    let nameField = LanguageNameField()

    private let levelControl = UISegmentedControl(items: LanguageLevel.allCases.map(\.displayName)).with {
        $0.selectedSegmentIndex = 0
        $0.accessibilityIdentifier = "language-level-control"
    }

    let deleteButton = Button(text: localize("profile.languages.edit.delete"), variant: .transparent, tone: .critical).with {
        $0.contentHorizontalAlignment = .leading
        $0.accessibilityIdentifier = "language-delete-button"
    }

    init() {
        let levelField = LabeledControl(title: localize("profile.languages.edit.levelLabel"), control: levelControl)
        super.init(fields: [nameField, levelField, deleteButton])
        accessibilityIdentifier = "profile-language-edit"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    var selectedLevel: LanguageLevel { LanguageLevel.allCases[levelControl.selectedSegmentIndex] }

    func configure(with viewModel: EditLanguageViewModel) {
        deleteButton.isHidden = !viewModel.showsDeleteButton
        guard let language = viewModel.languageProficiency else { return }
        nameField.setSelection(LanguageNameSuggestion(id: language.id, text: language.name))
        levelControl.selectedSegmentIndex = LanguageLevel.allCases.firstIndex(of: language.level) ?? 0
    }
}
