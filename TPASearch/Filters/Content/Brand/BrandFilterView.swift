import UIKit
import TPAUIKit
import TPAFoundation

final class BrandFilterView: UIView {
    let field = UITextField().with {
        $0.borderStyle = .roundedRect
        $0.placeholder = localize("search.filters.brand.any")
        $0.autocorrectionType = .no
        $0.accessibilityIdentifier = "filters-brand"
        $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    private let titleLabel = Label(typography: .headline, textColor: AppColors.text).with {
        $0.text = localize("search.filters.brand")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviewFill(VStack(spacing: 8, [titleLabel, field]), insets: .with(horizontal: 16, vertical: 8))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with viewModel: BrandFilterViewModel) {
        if field.text != viewModel.brand { field.text = viewModel.brand }
    }
}
