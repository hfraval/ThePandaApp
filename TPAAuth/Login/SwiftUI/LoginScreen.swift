import SwiftUI
import TPAUIKit
import TPAFoundation

/// SwiftUI Login screen — proves the unidirectional architecture works without a separate `View` +
/// `ViewController`. It resolves the read-only `@Observable` provider and owns it via `@State`
/// (data down — SwiftUI re-renders when `provider.viewModel` changes), keeps raw input as view-local
/// `@State`, validates with `ValidateLoginCommand`, and outputs through `LoginAction` (intent out).
///
/// Static copy (titles, placeholders, button text) is a View concern and lives here via `localize`.
/// The view model carries only the dynamic state: `.idle` / `.loading` / `.error`.
public struct LoginScreen: View {

    @State private var provider: any LoginViewModelProviderProtocol

    @State private var email = ""
    @State private var password = ""

    public init() {
        @Resolved var resolved: LoginViewModelProviderProtocol
        _provider = State(initialValue: resolved)
    }

    public var body: some View {
        ZStack {
            Color(AppColors.background).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "person")
                        .font(.system(size: 64))
                        .foregroundColor(Color(AppColors.primary))
                        .padding(.top, 48)

                    Text(localize("login.title"))
                        .font(.largeTitle).bold()
                        .multilineTextAlignment(.center)

                    Text(localize("login.subtitle"))
                        .font(.subheadline)
                        .foregroundColor(Color(AppColors.secondaryText))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)

                    TextField(localize("login.email.placeholder"), text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier("login-email-field")

                    SecureField(localize("login.password.placeholder"), text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                        .accessibilityIdentifier("login-password-field")

                    if case .error(let message) = provider.viewModel {
                        Text(message)
                            .font(.footnote)
                            .foregroundColor(Color(AppColors.error))
                            .multilineTextAlignment(.center)
                            .accessibilityIdentifier("login-error-label")
                    }

                    Button(action: submit) {
                        Text(localize("login.button.login"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(Color(AppColors.primary))
                            .cornerRadius(12)
                    }
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
                    .accessibilityIdentifier("login-button")
                }
                .padding(24)
            }

            if case .loading = provider.viewModel {
                Color(AppColors.background).opacity(0.85).ignoresSafeArea()
                ProgressView(localize("login.loading.message"))
            }
        }
    }

    /// View-local validation for button enablement — a pure `Command`, no service.
    private var isValid: Bool {
        ValidateLoginCommand()(email: email, password: password)
    }

    /// Intent out: resolve the action at the call site and fire it (results return as Events).
    private func submit() {
        @Resolved var loginAction: LoginActionProtocol
        loginAction(email: email, password: password)
    }
}
