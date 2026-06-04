import Foundation
import TPAFoundation

struct LoginViewModelFactory: Sendable {
    func make(isLoading: Bool = false, errorMessage: String? = nil) -> LoginViewModel {
        LoginViewModel(
            navigationTitle: localize("login.navigationTitle"),
            title: localize("login.title"),
            subtitle: localize("login.subtitle"),
            emailPlaceholder: localize("login.email.placeholder"),
            passwordPlaceholder: localize("login.password.placeholder"),
            loginButtonTitle: localize("login.button.login"),
            loadingMessage: localize("login.loading.message"),
            isLoading: isLoading,
            errorMessage: errorMessage
        )
    }
}
