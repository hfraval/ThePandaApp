import XCTest
import TPAUnitTestFoundation
@testable import TPADiscovery

@MainActor
final class DiscoveryScreenshotTests: ScreenshotTestCase {
    func test_discoveryScreen_underConstruction() {
        assertAppearance { DiscoveryViewController() }
    }
}
