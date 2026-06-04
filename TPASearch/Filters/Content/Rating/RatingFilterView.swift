import UIKit
import TPAUIKit
import TPAFoundation

final class RatingFilterView: UIView {
    let stepper = UIStepper().with {
        $0.minimumValue = 0
        $0.maximumValue = 5
        $0.stepValue = 1
        $0.accessibilityIdentifier = "filters-min-rating"
    }

    private let titleLabel = Label(typography: .headline, textColor: AppColors.text).with {
        $0.text = localize("search.filters.minRating")
    }
    private let valueLabel = Label(typography: .subheadline, textColor: AppColors.secondaryText)

    override init(frame: CGRect) {
        super.init(frame: frame)
        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        addSubviewFill(
            HStack(spacing: 12, alignment: .center, [titleLabel, Spacer(), valueLabel, stepper]),
            insets: .with(horizontal: 16, vertical: 8)
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func stepperChanged() {
        valueLabel.text = RatingFilterViewModel.label(for: stepper.value)
    }

    func configure(with viewModel: RatingFilterViewModel) {
        stepper.value = viewModel.value
        valueLabel.text = viewModel.displayText
    }
}
