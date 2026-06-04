import Foundation

@MainActor
public protocol ContentModelProviderDelegate: AnyObject {
    associatedtype TContentModel
    func contentModelUpdated(_ contentModel: TContentModel)
}

@MainActor
public final class AnyContentModelProviderDelegate<TContentModel>: ContentModelProviderDelegate {
    private let _contentModelUpdated: () -> ((TContentModel) -> Void)?

    public init<Delegate: ContentModelProviderDelegate>(_ delegate: Delegate)
    where Delegate.TContentModel == TContentModel {
        _contentModelUpdated = { [weak delegate] in
            delegate?.contentModelUpdated
        }
    }

    public func contentModelUpdated(_ contentModel: TContentModel) {
        _contentModelUpdated()?(contentModel)
    }
}
