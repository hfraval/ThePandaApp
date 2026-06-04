import UIKit

open class CoordinatedStackContentViewController<ContentModel>:
    StackContentViewController,
    ContentModelProviderDelegate
{
    public private(set) var contentModelProviderDelegate:
        AnyContentModelProviderDelegate<ContentModel>!

    public init(
        content: [AnyCoordinatedContent<ContentModel>],
        axis: NSLayoutConstraint.Axis = .vertical,
        scrollable: Bool = false,
        spacing: CGFloat = 0
    ) {
        super.init(content: content, axis: axis, scrollable: scrollable, spacing: spacing)
        contentModelProviderDelegate = AnyContentModelProviderDelegate(self)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func updateContent(with contentModel: ContentModel) {
        content
            .compactMap { $0 as? AnyCoordinatedContent<ContentModel> }
            .forEach {
                $0.shouldShow(for: contentModel) ? $0.show() : $0.hide()
                $0.update(for: contentModel)?()
            }
    }

    public func contentModelUpdated(_ contentModel: ContentModel) {
        updateContent(with: contentModel)
    }
}
