import XCTest
import TPAUnitTestFoundation
@testable import TPACore

@MainActor
final class ProfileModelsTests: AppTestCase {

    func test_languageLevel_hasFourCases_withDisplayNames() {
        XCTAssertEqual(LanguageLevel.allCases.count, 4)
        XCTAssertTrue(LanguageLevel.allCases.allSatisfy { !$0.displayName.isEmpty })
    }

    func test_availabilityAndApproachability_displayNamesNonEmpty() {
        XCTAssertTrue(Availability.allCases.allSatisfy { !$0.displayName.isEmpty })
        XCTAssertTrue(Approachability.allCases.allSatisfy { !$0.displayName.isEmpty })
    }

    func test_userProfile_fullName_joinsNonEmptyParts() {
        XCTAssertEqual(UserProfile(userId: "1", firstName: "Panda", lastName: "Bear", email: "").fullName, "Panda Bear")
        XCTAssertEqual(UserProfile(userId: "1", firstName: "", lastName: "Bear", email: "").fullName, "Bear")
        XCTAssertEqual(UserProfile(userId: "1", firstName: "", lastName: "", email: "").fullName, "")
    }

    func test_userProfile_codableRoundTrip_preservesLanguagesAndNextRole() throws {
        let original = UserProfile.mock
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(UserProfile.self, from: data)
        XCTAssertEqual(decoded, original)
    }

    func test_userProfile_defaultedInit_hasEmptySections() {
        let profile = UserProfile(userId: "1", firstName: "A", lastName: "B", email: "a@b.com")
        XCTAssertTrue(profile.languages.isEmpty)
        XCTAssertEqual(profile.nextRole, .empty)
    }
}
