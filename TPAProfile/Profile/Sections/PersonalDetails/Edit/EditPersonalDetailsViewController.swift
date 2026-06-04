import UIKit
import TPAUIKit
import TPAFoundation

public final class EditPersonalDetailsViewController: UIViewController, ModalCloseDelegate {
    private let editView = EditPersonalDetailsView()
    private let validate = ValidatePersonalDetailsCommand()

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func loadView() {
        view = editView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = localize("editProfile.navigationTitle")
        editView.configure(with: BuildEditPersonalDetailsViewModelCommand()())

        [editView.firstNameField, editView.lastNameField, editView.emailField].forEach {
            $0.addTarget(self, action: #selector(inputChanged), for: .editingChanged)
        }
        editView.saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        revalidate()
    }

    public func didTapCloseButton() {
        view.endEditing(true)
        dismiss(animated: true)
    }

    @objc private func inputChanged() { revalidate() }

    @objc private func saveTapped() {
        let result = currentValidation()
        editView.setFieldErrors(firstName: result.firstNameError, lastName: result.lastNameError, email: result.emailError)
        guard result.isValid else { return }

        @Resolved var save: SavePersonalDetailsActionProtocol
        save(
            firstName: editView.firstNameField.text ?? "",
            lastName: editView.lastNameField.text ?? "",
            email: editView.emailField.text ?? ""
        )
        dismiss(animated: true)
    }

    private func revalidate() {
        editView.setSaveEnabled(currentValidation().isValid)
    }

    private func currentValidation() -> PersonalDetailsValidation {
        validate(
            firstName: editView.firstNameField.text ?? "",
            lastName: editView.lastNameField.text ?? "",
            email: editView.emailField.text ?? ""
        )
    }
}
