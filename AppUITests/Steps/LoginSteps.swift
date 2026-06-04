import XCTest

protocol LoginSteps: Steps {}

extension LoginSteps where Self: XCTestCase {
    func The_Login_Screen_Is_Shown() {
        XCTAssertTrue(loginScreen.isVisible, "expected the login screen")
    }

    func The_Login_Button_Is_Disabled() {
        XCTAssertTrue(loginScreen.loginButton.waitToExist())
        XCTAssertFalse(loginScreen.loginButton.isEnabled)
    }

    func The_Login_Button_Is_Enabled() {
        XCTAssertTrue(loginScreen.loginButton.isEnabled)
    }

    func I_Enter_Valid_Credentials() {
        loginScreen.enterCredentials(email: "test@example.com", password: "password123")
    }

    func I_Submit_Login() {
        loginScreen.submit()
    }

    func The_Profile_Screen_Is_Shown() {
        XCTAssertTrue(profileScreen.isVisible, "expected the profile screen after signing in")
    }
}
