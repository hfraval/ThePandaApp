import UIKit
import TPAUIKit
import TPAFoundation

final class EditSalaryViewController: UIViewController {

    private let initialValue: String?
    private let onSave: (String?) -> Void

    private let field = UITextField().with {
        $0.borderStyle = .roundedRect
        $0.placeholder = localize("profile.nextRole.salary.placeholder")
        $0.accessibilityIdentifier = "salary-field"
        $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    init(initialValue: String?, onSave: @escaping (String?) -> Void) {
        self.initialValue = initialValue
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
        title = localize("profile.nextRole.salary.title")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        field.text = initialValue
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "salary-save-button"

        view.addSubview(field.withAutoLayout())
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            field.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            field.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            field.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16)
        ])
    }

    @objc private func cancelTapped() { dismiss(animated: true) }

    @objc private func saveTapped() {
        let trimmed = (field.text ?? "").trimmed
        onSave(trimmed.isEmpty ? nil : trimmed)
        dismiss(animated: true)
    }
}
