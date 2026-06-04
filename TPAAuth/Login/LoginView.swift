import UIKit
import TPAUIKit

final class LoginView: UIView {

    private let scrollView = UIScrollView().with {
        $0.alwaysBounceVertical = true
    }

    private let logoImageView = Image(systemIcon: .person).with {
        $0.tintColor = AppColors.primary
        $0.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 64, weight: .regular)
    }

    private let titleLabel = Label(typography: .largeTitle, textColor: AppColors.text, textAlignment: .center)

    private let subtitleLabel = Label(typography: .subheadline,
        textColor: AppColors.secondaryText,
        textAlignment: .center,
        numberOfLines: 0
    )

    let emailTextField = UITextField().with {
        $0.borderStyle = .roundedRect
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.keyboardType = .emailAddress
        $0.textContentType = .emailAddress
        $0.accessibilityIdentifier = "login-email-field"
        $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    let passwordTextField = UITextField().with {
        $0.borderStyle = .roundedRect
        $0.isSecureTextEntry = true
        $0.textContentType = .password
        $0.accessibilityIdentifier = "login-password-field"
        $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    let loginButton = Button(variant: .solid).with {
        $0.accessibilityIdentifier = "login-button"
    }

    private let errorLabel = Label(typography: .footnote,
        textColor: AppColors.error,
        textAlignment: .center,
        numberOfLines: 0
    ).with {
        $0.isHidden = true
        $0.accessibilityIdentifier = "login-error-label"
    }

    private let loadingView = LoadingView().with { $0.isHidden = true }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AppColors.background
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with viewModel: LoginViewModel) {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        emailTextField.placeholder = viewModel.emailPlaceholder
        passwordTextField.placeholder = viewModel.passwordPlaceholder
        loginButton.setTitle(viewModel.loginButtonTitle, for: .normal)

        if viewModel.isLoading {
            loadingView.message = viewModel.loadingMessage
            loadingView.startAnimating()
        } else {
            loadingView.stopAnimating()
        }

        errorLabel.text = viewModel.errorMessage
        errorLabel.isHidden = viewModel.errorMessage == nil
    }

    func setLoginEnabled(_ enabled: Bool) {
        loginButton.isEnabled = enabled
    }

    private func setup() {
        addSubviewFill(scrollView, safeArea: true)
        addSubviewFill(loadingView)

        let logoRow = VStack(alignment: .center, [logoImageView])
        let form = VStack(spacing: 12, [
            logoRow, titleLabel, subtitleLabel, emailTextField, passwordTextField, errorLabel, loginButton
        ])
        form.setCustomSpacing(20, after: logoRow)
        form.setCustomSpacing(8, after: titleLabel)
        form.setCustomSpacing(36, after: subtitleLabel)
        form.setCustomSpacing(24, after: errorLabel)

        scrollView.addSubview(form.withAutoLayout())
        NSLayoutConstraint.activate([
            form.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 48),
            form.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -48),
            form.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
            form.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
}
