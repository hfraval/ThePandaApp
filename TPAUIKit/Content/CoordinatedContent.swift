import UIKit

public typealias CoordinatedContentUpdate = () -> Void

public protocol CoordinatedContent: Content {
    associatedtype ContentModel
    func shouldShow(for model: ContentModel) -> Bool
    func update(for model: ContentModel) -> CoordinatedContentUpdate?
}

public final class AnyCoordinatedContent<TContentModel>: CoordinatedContent {
    private let _shouldAdd: () -> Bool
    private let _shouldShow: (TContentModel) -> Bool
    private let _update: (TContentModel) -> CoordinatedContentUpdate?
    private let _show: () -> Void
    private let _hide: () -> Void
    private let _viewController: UIViewController

    public init<C: CoordinatedContent>(_ content: C)
    where C.ContentModel == TContentModel, C: UIViewController {
        _shouldAdd = content.shouldAdd
        _shouldShow = content.shouldShow
        _update = content.update
        _show = content.show
        _hide = content.hide
        _viewController = content
    }

    public func shouldAdd() -> Bool { _shouldAdd() }
    public func shouldShow(for model: TContentModel) -> Bool { _shouldShow(model) }
    public func update(for model: TContentModel) -> CoordinatedContentUpdate? { _update(model) }
    public func show() { _show() }
    public func hide() { _hide() }
    public var viewController: UIViewController { _viewController }
}
