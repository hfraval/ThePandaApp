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

    weak var delegate: AnyViewModelProviderDelegate<LoginViewModel>? {
        didSet { updateDelegate() }
    }

    init(viewModelFactory: LoginViewModelFactory = .init()) {
        self.viewModelFactory = viewModelFactory
        observe(self, event: LoginEvents.Submitting.self, selector: #selector(handleSubmitting))
        observe(self, event: LoginEvents.Failed.self, selector: #selector(handleFailed(_:)))
        observe(self, event: LoginEvents.Succeeded.self, selector: #selector(handleReset))
        observe(self, event: AuthEvents.SignedOut.self, selector: #selector(handleReset))
    }

    @objc private func handleSubmitting() {
        isLoading = true
        errorMessage = nil
        updateDelegate()
    }

    @objc private func handleFailed(_ note: Notification) {
        isLoading = false
        errorMessage = (note.eventPayload() as LoginEvents.Failed?)?.reason
        updateDelegate()
    }

    @objc private func handleReset() {
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
