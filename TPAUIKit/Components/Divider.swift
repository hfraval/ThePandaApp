import UIKit

public final class Divider: UIView {
    public init(color: UIColor = AppColors.separator) {
        super.init(frame: .zero)
        backgroundColor = color
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 1)
    }
}
