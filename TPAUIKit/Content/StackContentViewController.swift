import UIKit

open class StackContentViewController: UIViewController {

    private let initialContent: [Content]
    private let _contentView: StackContentView

    public private(set) var content: [Content] = []

    public init(
        content: [Content],
        axis: NSLayoutConstraint.Axis = .vertical,
        scrollable: Bool = false,
        spacing: CGFloat = 0
    ) {
        self.initialContent = content
        self._contentView = StackContentView(axis: axis, scrollable: scrollable, spacing: spacing)
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open var contentView: StackContentView { _contentView }

    open override var shouldAutomaticallyForwardAppearanceMethods: Bool { false }

    open override func loadView() {
        view = contentView
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        initialContent.forEach(addContent)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        visibleChildren.forEach { $0.beginAppearanceTransition(true, animated: animated) }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        visibleChildren.forEach { $0.endAppearanceTransition() }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        visibleChildren.forEach { $0.beginAppearanceTransition(false, animated: animated) }
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        visibleChildren.forEach { $0.endAppearanceTransition() }
    }

    public func addContent(_ content: Content) {
        guard content.shouldAdd() else { return }

        self.content.append(content)
        addChild(content.viewController)
        contentView.addContent(content.viewController.view)
        content.viewController.didMove(toParent: self)
    }

    private var visibleChildren: [UIViewController] {
        content.map(\.viewController).filter { !$0.view.isHidden }
    }
}
