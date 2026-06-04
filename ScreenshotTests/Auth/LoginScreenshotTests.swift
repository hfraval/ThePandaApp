import XCTest
import TPAUIKit
import TPAUnitTestFoundation
@testable import TPAAuth

@MainActor
final class LoginScreenshotTests: ScreenshotTestCase {
    func test_loginScreen_empty() {
        assertAppearance { HostingContent(LoginScreen()) }
    }
}
