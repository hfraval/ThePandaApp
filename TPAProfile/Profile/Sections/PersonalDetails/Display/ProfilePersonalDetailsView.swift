import UIKit
import TPAUIKit

public final class ProfilePersonalDetailsView: UIView {

    private let avatarView = AvatarView(image: .asset(.brandLogo))

    private let nameLabel = Label(typography: .title2, textColor: .white, textAlignment: .center).with {
        $0.accessibilityIdentifier = "profile-name-label"
    }

    private let emailLabel = Label(typography: .subheadline,
        textColor: UIColor.white.withAlphaComponent(0.85),
        textAlignment: .center
    ).with {
        $0.accessibilityIdentifier = "profile-email-label"
    }

    private let emailIcon = Image(systemName: "envelope.fill", tintColor: UIColor.white.withAlphaComponent(0.85)).with {
        $0.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13, weight: .regular)
    }

    private lazy var emailRow = HStack(spacing: 4, alignment: .center, [emailIcon, emailLabel])

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = AppColors.primary

        let stack = VStack(spacing: 16, alignment: .center, [avatarView, nameLabel, emailRow])
        stack.setCustomSpacing(6, after: nameLabel)
        addSubviewFill(stack, insets: UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16))
    }

    func configure(with viewModel: ProfilePersonalDetailsViewModel) {
        nameLabel.text = viewModel.displayName
        emailLabel.text = viewModel.displayEmail
        emailRow.isHidden = !viewModel.showEmail
    }
}
