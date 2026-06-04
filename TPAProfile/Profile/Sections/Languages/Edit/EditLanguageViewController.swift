import UIKit
import TPACore
import TPAUIKit
import TPAFoundation

final class EditLanguageViewController: UIViewController, ModalCloseDelegate {

    private let viewModel: EditLanguageViewModel
    private let editView = EditProfileLanguageView()

    init(languageProficiency: LanguageProficiency?) {
        self.viewModel = EditLanguageViewModel(languageProficiency: languageProficiency)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        view = editView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.viewTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "language-save-button"

        editView.nameField.delegate = self
        editView.deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        editView.configure(with: viewModel)
        updateSaveEnabled()
    }

    private func updateSaveEnabled() {
        navigationItem.rightBarButtonItem?.isEnabled = editView.nameField.isValid
    }

    func didTapCloseButton() {
        view.endEditing(true)
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        guard let selection = editView.nameField.selection else { return }
        let language = LanguageProficiency(id: viewModel.id, name: selection.text, level: editView.selectedLevel)
        @Resolved var saveLanguage: SaveProfileLanguageActionProtocol
        saveLanguage(for: language)
        dismiss(animated: true)
    }

    @objc private func deleteTapped() {
        guard let id = viewModel.languageProficiency?.id else { return }
        @Resolved var deleteLanguage: DeleteProfileLanguageActionProtocol
        deleteLanguage(id: id)
        dismiss(animated: true)
    }
}

extension EditLanguageViewController: LanguageNameFieldDelegate {
    func languageNameField(_ field: LanguageNameField, present viewController: UIViewController) {
        present(viewController, animated: true)
    }

    func languageNameFieldSelectionChanged(_ field: LanguageNameField) {
        updateSaveEnabled()
    }
}
