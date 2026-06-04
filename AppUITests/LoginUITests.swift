import XCTest

final class LoginUITests: AppUITestCase, NavigationSteps, LoginSteps, SearchSteps {

    func test_profileTab_showsLoginScreen_whenSignedOut() {
        launch()
        Given.Open_The_Profile_Tab()
        Then.The_Login_Screen_Is_Shown()
    }

    func test_loginButton_isDisabled_whenFieldsEmpty() {
        launch()
        Given.Open_The_Profile_Tab()
        Then.The_Login_Button_Is_Disabled()
    }

    func test_loginButton_isEnabled_withValidCredentials() {
        launch()
        Given.Open_The_Profile_Tab()
        When.I_Enter_Valid_Credentials()
        Then.The_Login_Button_Is_Enabled()
    }

    func test_signIn_showsProfile() {
        launch()
        Given.Open_The_Profile_Tab()
        When.I_Enter_Valid_Credentials()
        And.I_Submit_Login()
        Then.The_Profile_Screen_Is_Shown()
    }

    func test_discoveryTab_showsUnderConstruction() {
        launch()
        Given.Open_The_Discovery_Tab()
        Then.The_Under_Construction_Text_Is_Shown()
    }
}
