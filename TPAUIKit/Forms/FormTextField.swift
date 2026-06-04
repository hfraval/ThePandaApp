import UIKit
import TPAFoundation

open class FormTextField: UIView {

    public let titleLabel = Label(typography: .subheadline, textColor: AppColors.secondaryText)

    public let textField = UITextField().with {
        $0.borderStyle = .roundedRect
        $0.autocorrectionType = .no
        $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    public init(title: String?, placeholder: String?) {
        super.init(frame: .zero)
        titleLabel.text = title
        titleLabel.isHidden = (title == nil)
        textField.placeholder = placeholder

        addSubviewFill(VStack(spacing: 4, [titleLabel, textField]))
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }
}
