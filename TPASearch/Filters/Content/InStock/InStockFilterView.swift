import UIKit
import TPAUIKit
import TPAFoundation

final class InStockFilterView: UIView {
    let toggle = UISwitch().with { $0.accessibilityIdentifier = "filters-in-stock" }

    private let titleLabel = Label(typography: .headline, textColor: AppColors.text).with {
        $0.text = localize("search.filters.inStock")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviewFill(
            HStack(spacing: 12, alignment: .center, [titleLabel, Spacer(), toggle]),
            insets: .with(horizontal: 16, vertical: 8)
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with viewModel: InStockFilterViewModel) {
        toggle.isOn = viewModel.isOn
    }
}
