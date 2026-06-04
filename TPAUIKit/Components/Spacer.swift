import UIKit

public final class Spacer: UIView {
    public init() {
        super.init(frame: .zero)
        setContentHuggingPriority(.init(1), for: .horizontal)
        setContentHuggingPriority(.init(1), for: .vertical)
        setContentCompressionResistancePriority(.init(1), for: .horizontal)
        setContentCompressionResistancePriority(.init(1), for: .vertical)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
