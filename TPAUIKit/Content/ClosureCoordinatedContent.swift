import UIKit

public final class ClosureCoordinatedContent<VC: UIViewController & Content, ContentModel>:
    UIViewController, CoordinatedContent
{
    private let child: VC
    private let _shouldShow: (ContentModel) -> Bool
    private let _update: (VC, ContentModel) -> CoordinatedContentUpdate?

    public init(
        _ child: VC,
        shouldShow: @escaping (ContentModel) -> Bool,
        update: @escaping (VC, ContentModel) -> CoordinatedContentUpdate? = { _, _ in nil }
    ) {
        self.child = child
        self._shouldShow = shouldShow
        self._update = update
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        addChild(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(child.view)
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        child.didMove(toParent: self)
    }

    public func shouldAdd() -> Bool { child.shouldAdd() }
    public func shouldShow(for model: ContentModel) -> Bool { _shouldShow(model) }
    public func update(for model: ContentModel) -> CoordinatedContentUpdate? { _update(child, model) }
}
