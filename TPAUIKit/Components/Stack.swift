import UIKit

@resultBuilder
public enum StackContentBuilder {
    public static func buildExpression(_ view: UIView) -> [UIView] { [view] }
    public static func buildExpression(_ views: [UIView]) -> [UIView] { views }
    public static func buildBlock(_ parts: [UIView]...) -> [UIView] { parts.flatMap { $0 } }
    public static func buildOptional(_ part: [UIView]?) -> [UIView] { part ?? [] }
    public static func buildEither(first: [UIView]) -> [UIView] { first }
    public static func buildEither(second: [UIView]) -> [UIView] { second }
    public static func buildArray(_ parts: [[UIView]]) -> [UIView] { parts.flatMap { $0 } }
}

public final class VStack: UIStackView {
    public init(
        spacing: CGFloat = 0,
        alignment: Alignment = .fill,
        distribution: Distribution = .fill,
        layoutMargins: UIEdgeInsets? = nil,
        @StackContentBuilder content: () -> [UIView] = { [] }
    ) {
        super.init(frame: .zero)
        axis = .vertical
        self.spacing = spacing
        self.alignment = alignment
        self.distribution = distribution
        applyLayoutMargins(layoutMargins)
        setContent(content)
    }

    public convenience init(spacing: CGFloat = 0, alignment: Alignment = .fill, _ views: [UIView]) {
        self.init(spacing: spacing, alignment: alignment) { views }
    }

    public required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @discardableResult
    public func setContent(@StackContentBuilder _ content: () -> [UIView]) -> Self {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
        content().forEach { addArrangedSubview($0) }
        return self
    }
}

public final class HStack: UIStackView {
    public init(
        spacing: CGFloat = 0,
        alignment: Alignment = .fill,
        distribution: Distribution = .fill,
        layoutMargins: UIEdgeInsets? = nil,
        @StackContentBuilder content: () -> [UIView] = { [] }
    ) {
        super.init(frame: .zero)
        axis = .horizontal
        self.spacing = spacing
        self.alignment = alignment
        self.distribution = distribution
        applyLayoutMargins(layoutMargins)
        setContent(content)
    }

    public convenience init(spacing: CGFloat = 0, alignment: Alignment = .fill, _ views: [UIView]) {
        self.init(spacing: spacing, alignment: alignment) { views }
    }

    public required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @discardableResult
    public func setContent(@StackContentBuilder _ content: () -> [UIView]) -> Self {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
        content().forEach { addArrangedSubview($0) }
        return self
    }
}

private extension UIStackView {
    func applyLayoutMargins(_ insets: UIEdgeInsets?) {
        guard let insets else { return }
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = insets
    }
}
