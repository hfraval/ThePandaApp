import UIKit
import TPAUIKit

final class SettingsRowView: UIView {
    let button = Button(variant: .transparent).with {
        $0.contentEdgeInsets = .zero
        $0.contentHorizontalAlignment = .leading
        $0.titleLabel?.font = AppTypography.body
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.heightAnchor.constraint(equalToConstant: 52).isActive = true
    }

    private let chevron = Image(systemName: "chevron.right", tintColor: AppColors.secondaryText).with {
        $0.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }

    private let separator = Divider()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AppColors.background

        addSubviewFill(
            HStack(spacing: 8, alignment: .center, [button, chevron]),
            insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        )

        addSubview(separator.withAutoLayout())
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with viewModel: SettingsRowViewModel) {
        button.setTitle(viewModel.title, for: .normal)
        switch viewModel.style {
        case .navigational:
            button.setTitleColor(AppColors.text, for: .normal)
            chevron.isHidden = false
        case .destructive:
            button.setTitleColor(AppColors.error, for: .normal)
            chevron.isHidden = true
        }
    }
}
