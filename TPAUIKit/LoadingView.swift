import UIKit

public final class LoadingView: UIView {
    private let activityIndicator = UIActivityIndicatorView(style: .large).with {
        $0.color = AppColors.primary
    }

    private let messageLabel = Label(typography: .subheadline,
        textColor: AppColors.secondaryText,
        textAlignment: .center,
        numberOfLines: 0
    )

    public var message: String? {
        get { messageLabel.text }
        set { messageLabel.text = newValue }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = AppColors.background.withAlphaComponent(0.85)

        let stack = VStack(spacing: 12, alignment: .center, [activityIndicator, messageLabel])
        addSubview(stack.withAutoLayout())
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20)
        ])
    }

    public func startAnimating() {
        isHidden = false
        activityIndicator.startAnimating()
    }

    public func stopAnimating() {
        activityIndicator.stopAnimating()
        isHidden = true
    }
}
