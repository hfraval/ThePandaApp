import UIKit
import TPAUIKit
import TPAFoundation

final class LanguagesEmptyView: UIView {

    private let messageLabel = Label(typography: .body,
        textColor: AppColors.secondaryText,
        numberOfLines: 0
    ).with {
        $0.text = localize("profile.languages.empty.message")
    }

    private let addButton = Button(text: localize("profile.languages.empty.add"), variant: .transparent).with {
        $0.contentHorizontalAlignment = .leading
        $0.accessibilityIdentifier = "languages-empty-add-button"
    }

    var onAdd: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityIdentifier = "languages-empty-view"
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addSubviewFill(
            VStack(spacing: 8, [messageLabel, addButton]),
            insets: UIEdgeInsets(top: 4, left: 16, bottom: 8, right: 16)
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func addTapped() { onAdd?() }
}
