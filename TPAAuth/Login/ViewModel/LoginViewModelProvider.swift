import Foundation
import TPACore
import TPAFoundation
import Observation

@MainActor
protocol LoginViewModelProviderProtocol: AnyObject {
    var viewModel: LoginViewModel { get }
}

/// Read-only source of the login screen's render state. SwiftUI-native: it's `@Observable` and the
/// `LoginScreen` resolves it and owns it via `@State`, so writing `viewModel` re-renders the view
/// automatically — no delegate, no bridge. Data flows one way: the provider is the only writer; the
/// view only reads.
@MainActor
@Observable
final class LoginViewModelProvider: LoginViewModelProviderProtocol {

    private(set) var viewModel: LoginViewModel = .idle

    /// Owns the event subscriptions; cancels them when this provider is released. Not view state.
    @ObservationIgnored
    private let observations = EventObservations()

    init() {
        observations.observe(LoginEvents.Submitting.self, on: self) { provider, _ in provider.viewModel = .loading }
        observations.observe(LoginEvents.Failed.self, on: self) { provider, event in provider.viewModel = .error(message: event.reason) }
        observations.observe(LoginEvents.Succeeded.self, on: self) { provider, _ in provider.viewModel = .idle }
        observations.observe(AuthEvents.SignedOut.self, on: self) { provider, _ in provider.viewModel = .idle }
    }
}
