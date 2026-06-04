import Foundation

@MainActor
public protocol ViewModelProviderDelegate: AnyObject {
    associatedtype TViewModel
    func viewModelUpdated(_ viewModel: TViewModel)
}

@MainActor
public final class AnyViewModelProviderDelegate<TViewModel>: ViewModelProviderDelegate {
    private let _viewModelUpdated: () -> ((TViewModel) -> Void)?

    public init<Delegate: ViewModelProviderDelegate>(_ delegate: Delegate)
    where Delegate.TViewModel == TViewModel {
        _viewModelUpdated = { [weak delegate] in
            delegate?.viewModelUpdated
        }
    }

    public func viewModelUpdated(_ viewModel: TViewModel) {
        _viewModelUpdated()?(viewModel)
    }
}
