import Combine

/// Bridges a read-only `…ViewModelProvider` (which pushes an immutable view model via a weak
/// `AnyViewModelProviderDelegate`) into SwiftUI. It *is* the provider's delegate and re-publishes
/// each pushed view model as `@Published`, so a SwiftUI view can observe it with `@StateObject`.
///
/// Data still flows one way: the provider pushes; this store only republishes. The view never
/// writes back through it.
///
/// ```swift
/// @StateObject private var store = ViewModelStore<LoginViewModel>(LoginViewModelProvider()) {
///     provider, delegate in provider.delegate = delegate
/// }
/// ```
@MainActor
public final class ViewModelStore<ViewModel>: ObservableObject, ViewModelProviderDelegate {

    @Published public private(set) var viewModel: ViewModel?

    /// Retained so the provider outlives the view (the provider holds the delegate weakly).
    private let provider: AnyObject
    private var delegate: AnyViewModelProviderDelegate<ViewModel>?

    /// - Parameters:
    ///   - provider: the screen's view-model provider (held strongly).
    ///   - connect: wires this store as the provider's delegate, e.g. `{ p, d in p.delegate = d }`.
    ///     Setting the delegate typically triggers an immediate first push.
    public init<Provider: AnyObject>(
        _ provider: Provider,
        connect: (Provider, AnyViewModelProviderDelegate<ViewModel>) -> Void
    ) {
        self.provider = provider
        let anyDelegate = AnyViewModelProviderDelegate(self)
        self.delegate = anyDelegate
        connect(provider, anyDelegate)
    }

    public func viewModelUpdated(_ viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}
