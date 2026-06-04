import UIKit
import TPAUIKit
import TPAFoundation

final class EditPersonalDetailsView: UIView {

    let firstNameField = EditPersonalDetailsView.field(id: "edit-first-name-field")
    let lastNameField = EditPersonalDetailsView.field(id: "edit-last-name-field")
    let emailField = EditPersonalDetailsView.field(id: "edit-email-field").with {
        $0.keyboardType = .emailAddress
        $0.textContentType = .emailAddress
        $0.autocapitalizationType = .none
    }

    let saveButton = Button(variant: .solid).with {
        $0.accessibilityIdentifier = "edit-save-button"
    }

    private let firstNameLabel = EditPersonalDetailsView.fieldLabel()
    private let lastNameLabel = EditPersonalDetailsView.fieldLabel()
    private let emailLabel = EditPersonalDetailsView.fieldLabel()
    private let firstNameError = EditPersonalDetailsView.errorLabel(id: "edit-first-name-error")
    private let lastNameError = EditPersonalDetailsView.errorLabel(id: "edit-last-name-error")
    private let emailError = EditPersonalDetailsView.errorLabel(id: "edit-email-error")

    private let stack = VStack(spacing: 16).with {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AppColors.background
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with viewModel: EditPersonalDetailsViewModel) {
        firstNameField.text = viewModel.firstName
        lastNameField.text = viewModel.lastName
        emailField.text = viewModel.email
    }

    func setFieldErrors(firstName: String?, lastName: String?, email: String?) {
        apply(firstName, to: firstNameError)
        apply(lastName, to: lastNameError)
        apply(email, to: emailError)
    }

    func setSaveEnabled(_ enabled: Bool) {
        saveButton.isEnabled = enabled
    }

    private func apply(_ message: String?, to label: UILabel) {
        label.text = message
        label.isHidden = message == nil
    }

    private func setup() {
        firstNameLabel.text = localize("editProfile.firstName.label")
        lastNameLabel.text = localize("editProfile.lastName.label")
        emailLabel.text = localize("editProfile.email.label")
        firstNameField.placeholder = localize("editProfile.firstName.placeholder")
        lastNameField.placeholder = localize("editProfile.lastName.placeholder")
        emailField.placeholder = localize("editProfile.email.placeholder")
        saveButton.setTitle(localize("editProfile.button.save"), for: .normal)

        [firstNameLabel, firstNameField, firstNameError,
         lastNameLabel, lastNameField, lastNameError,
         emailLabel, emailField, emailError,
         saveButton].forEach { stack.addArrangedSubview($0) }
        stack.setCustomSpacing(4, after: firstNameLabel)
        stack.setCustomSpacing(4, after: lastNameLabel)
        stack.setCustomSpacing(4, after: emailLabel)
        stack.setCustomSpacing(24, after: emailError)

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            saveButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private static func field(id: String) -> UITextField {
        UITextField().with {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.borderStyle = .roundedRect
            $0.autocorrectionType = .no
            $0.accessibilityIdentifier = id
            $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
        }
    }

    private static func fieldLabel() -> UILabel {
        Label(typography: .subheadline, textColor: AppColors.secondaryText)
    }

    private static func errorLabel(id: String) -> UILabel {
        Label(typography: .footnote, textColor: AppColors.error, numberOfLines: 0).with {
            $0.isHidden = true
            $0.accessibilityIdentifier = id
        }
    }
}
