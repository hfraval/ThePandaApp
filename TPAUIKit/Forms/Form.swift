import UIKit

open class Form: UIView {

    public let stackView = VStack(spacing: 20)

    public init(fields: [UIView]) {
        super.init(frame: .zero)
        backgroundColor = AppColors.background
        fields.forEach { stackView.addArrangedSubview($0) }
        addSubview(stackView.withAutoLayout())
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
