import UIKit

public final class DisclosureRowView: UIView {

    private let titleLabel = Label(typography: .headline, textColor: AppColors.text)
    private let valueLabel = Label(typography: .subheadline, textColor: AppColors.secondaryText, numberOfLines: 0)
    private let chevron = Image(systemName: "chevron.right", tintColor: AppColors.secondaryText).with {
        $0.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }

    public var onTap: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        let textStack = VStack(spacing: 2, [titleLabel, valueLabel])
        let row = HStack(spacing: 8, alignment: .center, [textStack, chevron])
        addSubviewFill(row, insets: UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16))

        let separator = Divider()
        addSubview(separator.withAutoLayout())
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public func configure(title: String, value: String?, placeholder: String? = nil) {
        titleLabel.text = title
        let shown = value ?? placeholder
        valueLabel.text = shown
        valueLabel.isHidden = (shown == nil)
        valueLabel.textColor = (value == nil) ? AppColors.secondaryText : AppColors.text
    }

    @objc private func tapped() { onTap?() }
}
