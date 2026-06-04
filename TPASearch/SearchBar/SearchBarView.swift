import UIKit
import TPAUIKit

final class SearchBarView: UIView {

    private let promptLabel = Label(typography: .headline, textColor: .white, numberOfLines: 0)

    let keywordsField = UITextField().with {
        $0.borderStyle = .roundedRect
        $0.backgroundColor = .white
        $0.autocorrectionType = .no
        $0.returnKeyType = .search
        $0.accessibilityIdentifier = "search-keywords-field"
        $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    let searchButton = Button(variant: .solid).with {
        $0.backgroundColor = .white
        $0.setTitleColor(AppColors.primary, for: .normal)
        $0.accessibilityIdentifier = "search-button"
        $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AppColors.primary
        addSubviewFill(
            VStack(spacing: 10, [promptLabel, keywordsField, searchButton]),
            insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
            safeArea: true
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with viewModel: SearchBarViewModel) {
        promptLabel.text = viewModel.prompt
        keywordsField.placeholder = viewModel.keywordsPlaceholder
        searchButton.setTitle(viewModel.searchButtonTitle, for: .normal)
    }
}
