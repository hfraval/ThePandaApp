import UIKit
import TPAUIKit
import TPAFoundation

public final class LoginViewController: UIViewController {
    private let loginView = LoginView()

    private let viewModelProvider: LoginViewModelProviderProtocol
    private var anyViewModelProviderDelegate: AnyViewModelProviderDelegate<LoginViewModel>?

    private let validate = ValidateLoginCommand()

    init(viewModelProvider: LoginViewModelProviderProtocol = LoginViewModelProvider()) {
        self.viewModelProvider = viewModelProvider
        super.init(nibName: nil, bundle: nil)
        anyViewModelProviderDelegate = .init(self)
    }

    public convenience init() {
        self.init(viewModelProvider: LoginViewModelProvider())
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func loadView() {
        view = loginView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        loginView.emailTextField.addTarget(self, action: #selector(inputChanged), for: .editingChanged)
        loginView.passwordTextField.addTarget(self, action: #selector(inputChanged), for: .editingChanged)
        loginView.loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        viewModelProvider.delegate = anyViewModelProviderDelegate
        updateLoginEnabled()
    }

    @objc private func inputChanged() {
        updateLoginEnabled()
    }

    @objc private func loginTapped() {
        @Resolved var login: LoginActionProtocol
        login(
            email: loginView.emailTextField.text ?? "",
            password: loginView.passwordTextField.text ?? ""
        )
    }

    private func updateLoginEnabled() {
        let enabled = validate(
            email: loginView.emailTextField.text ?? "",
            password: loginView.passwordTextField.text ?? ""
        )
        loginView.setLoginEnabled(enabled)
    }
}

extension LoginViewController: ViewModelProviderDelegate {
    public func viewModelUpdated(_ viewModel: LoginViewModel) {
        title = viewModel.navigationTitle
        loginView.configure(with: viewModel)
        updateLoginEnabled()
    }
}

extension LoginViewController: Content {
    public func shouldAdd() -> Bool { true }
}
