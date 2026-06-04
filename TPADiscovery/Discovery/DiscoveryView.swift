import UIKit
import TPAUIKit

final class DiscoveryView: UIView {

    private let iconImageView = Image(systemIcon: .safari).with {
        $0.tintColor = AppColors.secondaryText
        $0.accessibilityIdentifier = "discovery-icon"
        $0.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 64, weight: .regular)
    }

    private let titleLabel = Label(typography: .title2, textColor: AppColors.text, textAlignment: .center).with {
        $0.accessibilityIdentifier = "discovery-title"
    }

    private let subtitleLabel = Label(typography: .body,
        textColor: AppColors.secondaryText,
        textAlignment: .center,
        numberOfLines: 0
    )

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AppColors.background
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with viewModel: DiscoveryViewModel) {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
    }

    private func setup() {
        let stack = VStack(spacing: 8, alignment: .center, [iconImageView, titleLabel, subtitleLabel])
        stack.setCustomSpacing(20, after: iconImageView)
        addSubview(stack.withAutoLayout())

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)
        ])
    }
}
