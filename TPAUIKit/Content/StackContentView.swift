import UIKit

open class StackContentView: UIView {

    public let stackView = UIStackView()
    public private(set) var scrollView: UIScrollView?

    public init(axis: NSLayoutConstraint.Axis, scrollable: Bool, spacing: CGFloat = 0) {
        super.init(frame: .zero)

        stackView.axis = axis
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollable ? installScrollingStack() : installFixedStack()
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    open func addContent(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }

    private func installScrollingStack() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView = scrollView
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func installFixedStack() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
