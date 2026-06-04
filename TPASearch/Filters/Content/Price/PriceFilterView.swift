import UIKit
import TPAUIKit
import TPAFoundation

final class PriceFilterView: UIView {
    let slider = UISlider().with {
        $0.minimumValue = 0
        $0.maximumValue = 2000
        $0.accessibilityIdentifier = "filters-max-price"
    }

    private let titleLabel = Label(typography: .headline, textColor: AppColors.text).with {
        $0.text = localize("search.filters.maxPrice")
    }
    private let valueLabel = Label(typography: .subheadline, textColor: AppColors.secondaryText)

    override init(frame: CGRect) {
        super.init(frame: frame)
        slider.addTarget(self, action: #selector(sliderMoved), for: .valueChanged)
        let header = HStack(spacing: 8, alignment: .center, [titleLabel, Spacer(), valueLabel])
        addSubviewFill(VStack(spacing: 8, [header, slider]), insets: .with(horizontal: 16, vertical: 8))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func sliderMoved() {
        valueLabel.text = PriceFilterViewModel.label(for: slider.value)
    }

    func configure(with viewModel: PriceFilterViewModel) {
        slider.value = viewModel.value
        valueLabel.text = viewModel.displayText
    }
}
