import SwiftUI
import TPAUIKit
import TPAFoundation

/// SwiftUI Login screen — the pilot proving the unidirectional architecture works without a
/// separate `View` + `ViewController`. It owns the read-only `LoginViewModelProvider` via a
/// `ViewModelStore` (data down), keeps raw input as view-local `@State`, validates with
/// `ValidateLoginCommand`, and outputs through `LoginAction` (intent out). The provider/action/
/// service/event layer is unchanged.
public struct LoginScreen: View {

    @State private var store = ViewModelStore<LoginViewModel>(LoginViewModelProvider()) {
        provider, delegate in provider.delegate = delegate
    }

    @State private var email = ""
    @State private var password = ""

    public init() {}

    public var body: some View {
        ZStack {
            Color(AppColors.background).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "person")
                        .font(.system(size: 64))
                        .foregroundColor(Color(AppColors.primary))
                        .padding(.top, 48)

                    Text(store.viewModel?.title ?? "")
                        .font(.largeTitle).bold()
                        .multilineTextAlignment(.center)

                    Text(store.viewModel?.subtitle ?? "")
                        .font(.subheadline)
                        .foregroundColor(Color(AppColors.secondaryText))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)

                    TextField(store.viewModel?.emailPlaceholder ?? "", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier("login-email-field")

                    SecureField(store.viewModel?.passwordPlaceholder ?? "", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                        .accessibilityIdentifier("login-password-field")

                    if let error = store.viewModel?.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(Color(AppColors.error))
                            .multilineTextAlignment(.center)
                            .accessibilityIdentifier("login-error-label")
                    }

                    Button(action: submit) {
                        Text(store.viewModel?.loginButtonTitle ?? "")
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

            if store.viewModel?.isLoading == true {
                Color(AppColors.background).opacity(0.85).ignoresSafeArea()
                ProgressView(store.viewModel?.loadingMessage ?? "")
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
