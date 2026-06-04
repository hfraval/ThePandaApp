import XCTest
import TPAUnitTestFoundation
@testable import TPAProfile

@MainActor
final class ProfileViewControllerTests: AppTestCase {

    func test_composesExpectedChildrenInOrder() {
        let vc = ProfileViewController()
        vc.loadViewIfNeeded()

        XCTAssertEqual(vc.content.count, 5)
        XCTAssertTrue(vc.content[0].viewController is ProfilePersonalDetailsViewController)
        XCTAssertTrue(vc.content[1].viewController is ProfileSectionTabBarViewController)
        XCTAssertTrue(vc.content[2].viewController is ProfileLanguagesSectionViewController)
        XCTAssertTrue(vc.content[3].viewController is SpacerSectionViewController)
        XCTAssertTrue(vc.content[4].viewController is ProfileNextRoleSectionViewController)
    }
}
