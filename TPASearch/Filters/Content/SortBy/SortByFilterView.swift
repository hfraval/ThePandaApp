import UIKit
import TPAUIKit
import TPAFoundation

final class SortByFilterView: UIView {
    let control = UISegmentedControl(items: [
        localize("search.filters.sort.relevance"),
        localize("search.filters.sort.title"),
        localize("search.filters.sort.price"),
        localize("search.filters.sort.rating")
    ]).with {
        $0.accessibilityIdentifier = "filters-sort"
    }

    private let titleLabel = Label(typography: .headline, textColor: AppColors.text).with {
        $0.text = localize("search.filters.sort")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviewFill(VStack(spacing: 8, [titleLabel, control]), insets: .with(horizontal: 16, vertical: 8))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with viewModel: SortByFilterViewModel) {
        control.selectedSegmentIndex = viewModel.selectedIndex
    }
}
