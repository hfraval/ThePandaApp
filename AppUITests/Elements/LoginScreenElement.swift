import XCTest

struct LoginScreenElement {
    private var app: XCUIApplication { XCUIApplication() }

    var emailField: XCUIElement { app.textFields["login-email-field"] }
    var passwordField: XCUIElement { app.secureTextFields["login-password-field"] }
    var loginButton: XCUIElement { app.buttons["login-button"] }
    var errorLabel: XCUIElement { app.staticTexts["login-error-label"] }

    var isVisible: Bool { emailField.waitToExist() }

    @discardableResult
    func enterCredentials(email: String, password: String) -> LoginScreenElement {
        emailField.type(email)
        passwordField.type(password)
        return self
    }

    func submit() {
        loginButton.tapWhenReady()
    }
}
