import UIKit
import TPAFoundation

public final class LabeledControl: UIView {
    public init(title: String, control: UIView, spacing: CGFloat = 4) {
        super.init(frame: .zero)

        let titleLabel = Label(typography: .subheadline, textColor: AppColors.secondaryText).with {
            $0.text = title
        }

        addSubviewFill(VStack(spacing: spacing, [titleLabel, control]))
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
