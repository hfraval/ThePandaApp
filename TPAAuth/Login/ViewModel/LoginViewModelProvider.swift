import Foundation
import TPACore
import TPAFoundation
import TPAUIKit

@MainActor
protocol LoginViewModelProviderProtocol: AnyObject {
    var delegate: AnyViewModelProviderDelegate<LoginViewModel>? { get set }
}

@MainActor
final class LoginViewModelProvider: LoginViewModelProviderProtocol {
    private let viewModelFactory: LoginViewModelFactory

    private var isLoading = false
    private var errorMessage: String?

    /// One long-lived consumer task per observed event; cancelled in `deinit` to remove the
    /// underlying observers.
    private var observationTasks: [Task<Void, Never>] = []

    weak var delegate: AnyViewModelProviderDelegate<LoginViewModel>? {
        didSet { updateDelegate() }
    }

    init(viewModelFactory: LoginViewModelFactory = .init()) {
        self.viewModelFactory = viewModelFactory
        observationTasks = [
            Task { [weak self] in
                for await _ in events(of: LoginEvents.Submitting.self) { self?.handleSubmitting() }
            },
            Task { [weak self] in
                for await event in events(of: LoginEvents.Failed.self) { self?.handleFailed(event) }
            },
            Task { [weak self] in
                for await _ in events(of: LoginEvents.Succeeded.self) { self?.handleReset() }
            },
            Task { [weak self] in
                for await _ in events(of: AuthEvents.SignedOut.self) { self?.handleReset() }
            },
        ]
    }

    deinit {
        observationTasks.forEach { $0.cancel() }
    }

    private func handleSubmitting() {
        isLoading = true
        errorMessage = nil
        updateDelegate()
    }

    private func handleFailed(_ event: LoginEvents.Failed) {
        isLoading = false
        errorMessage = event.reason
        updateDelegate()
    }

    private func handleReset() {
        isLoading = false
        errorMessage = nil
        updateDelegate()
    }

    private func updateDelegate() {
        delegate?.viewModelUpdated(
            viewModelFactory.make(isLoading: isLoading, errorMessage: errorMessage)
        )
    }
}
