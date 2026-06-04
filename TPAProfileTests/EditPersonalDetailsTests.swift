import XCTest
import TPACore
import TPAFoundation
import TPAUIKit
import TPAUnitTestFoundation
@testable import TPAProfile

@MainActor
final class ValidatePersonalDetailsCommandTests: AppTestCase {
    private let validate = ValidatePersonalDetailsCommand()

    func test_allValid() {
        let result = validate(firstName: "Panda", lastName: "Bear", email: "p@example.com")
        XCTAssertTrue(result.isValid)
        XCTAssertNil(result.firstNameError)
        XCTAssertNil(result.emailError)
    }

    func test_emptyNames_areRequired() {
        let result = validate(firstName: "  ", lastName: "", email: "p@example.com")
        XCTAssertNotNil(result.firstNameError)
        XCTAssertNotNil(result.lastNameError)
        XCTAssertFalse(result.isValid)
    }

    func test_invalidEmail() {
        let result = validate(firstName: "Panda", lastName: "Bear", email: "not-an-email")
        XCTAssertNotNil(result.emailError)
        XCTAssertFalse(result.isValid)
    }
}

@MainActor
final class BuildEditPersonalDetailsViewModelCommandTests: AppTestCase {
    @MockResolved<ProfileServiceProtocol, MockProfileService> var _profile

    func test_build_seedsFieldsFromCurrentProfile() {
        _profile.profile = .mock
        let viewModel = BuildEditPersonalDetailsViewModelCommand()()
        XCTAssertEqual(viewModel.firstName, UserProfile.mock.firstName)
        XCTAssertEqual(viewModel.lastName, UserProfile.mock.lastName)
        XCTAssertEqual(viewModel.email, UserProfile.mock.email)
    }

    func test_build_emptyFieldsWhenNoProfile() {
        _profile.profile = nil
        let viewModel = BuildEditPersonalDetailsViewModelCommand()()
        XCTAssertEqual(viewModel.firstName, "")
        XCTAssertEqual(viewModel.lastName, "")
        XCTAssertEqual(viewModel.email, "")
    }
}

@MainActor
final class SavePersonalDetailsActionTests: AppTestCase {
    @MockResolved<ProfileServiceProtocol, MockProfileService> var _profile

    override func setUp() async throws {
        try await super.setUp()
        _profile.profile = .mock
    }

    func test_save_persistsTrimmedDetails_preservesRest_andPostsUpdated() {
        var updated = false
        let center = ServiceContainer.shared.resolve(NotificationCenter.self)
        let token = center.addObserver(forName: ProfileEvents.Updated.notificationName, object: nil, queue: nil) { _ in updated = true }
        defer { center.removeObserver(token) }

        SavePersonalDetailsAction()(firstName: "  Red  ", lastName: " Panda ", email: " red@panda.com ")

        XCTAssertEqual(_profile.lastSavedProfile?.firstName, "Red")
        XCTAssertEqual(_profile.lastSavedProfile?.lastName, "Panda")
        XCTAssertEqual(_profile.lastSavedProfile?.email, "red@panda.com")
        XCTAssertEqual(_profile.lastSavedProfile?.languages, UserProfile.mock.languages)
        XCTAssertTrue(updated)
    }
}
