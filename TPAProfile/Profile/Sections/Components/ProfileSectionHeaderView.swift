import UIKit
import TPAUIKit

final class ProfileSectionHeaderView: UIView {

    private let titleLabel = Label(typography: .title2, textColor: AppColors.text).with {
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }

    private let actionButton = Button(variant: .transparent).with {
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }

    var onAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        addSubviewFill(
            HStack(spacing: 8, alignment: .center, [titleLabel, actionButton]),
            insets: UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, actionTitle: String?) {
        titleLabel.text = title
        actionButton.setTitle(actionTitle, for: .normal)
        actionButton.isHidden = actionTitle == nil
    }

    @objc private func actionTapped() { onAction?() }
}
