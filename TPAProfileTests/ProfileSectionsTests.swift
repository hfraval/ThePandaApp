import XCTest
import TPACore
import TPAFoundation
import TPAUIKit
import TPAUnitTestFoundation
@testable import TPAProfile

@MainActor
final class ProfileSectionViewModelTests: AppTestCase {
    func test_languagesViewModel_readsLanguages() {
        XCTAssertEqual(LanguagesViewModel.make(profile: .mock).languages, UserProfile.mock.languages)
        XCTAssertTrue(LanguagesViewModel.make(profile: nil).languages.isEmpty)
    }

    func test_nextRoleViewModel_readsPreferences() {
        XCTAssertEqual(NextRoleViewModel.make(profile: .mock).preferences, UserProfile.mock.nextRole)
        XCTAssertEqual(NextRoleViewModel.make(profile: nil).preferences, .empty)
    }

    func test_editLanguageViewModel_addMode() {
        let viewModel = EditLanguageViewModel(languageProficiency: nil)
        XCTAssertEqual(viewModel.mode, .add)
        XCTAssertFalse(viewModel.showsDeleteButton)
        XCTAssertEqual(viewModel.viewTitle, localize("profile.languages.edit.addTitle"))
        XCTAssertFalse(viewModel.id.isEmpty)
    }

    func test_editLanguageViewModel_editMode_reusesExistingId() {
        let language = LanguageProficiency(id: "lang-english", name: "English", level: .fluent)
        let viewModel = EditLanguageViewModel(languageProficiency: language)
        XCTAssertEqual(viewModel.mode, .edit)
        XCTAssertTrue(viewModel.showsDeleteButton)
        XCTAssertEqual(viewModel.viewTitle, localize("profile.languages.edit.editTitle"))
        XCTAssertEqual(viewModel.id, "lang-english")
    }
}

@MainActor
final class ProfileSectionActionsTests: AppTestCase {
    @MockResolved<ProfileServiceProtocol, MockProfileService> var _profile

    override func setUp() async throws {
        try await super.setUp()
        _profile.profile = .mock
    }

    func test_saveLanguageAction_upsertsAndPostsUpdated() {
        var updated = false
        let center = ServiceContainer.shared.resolve(NotificationCenter.self)
        let token = center.addObserver(forName: ProfileEvents.Updated.notificationName, object: nil, queue: nil) { _ in updated = true }
        defer { center.removeObserver(token) }

        SaveProfileLanguageAction()(for: LanguageProficiency(id: "new", name: "Spanish", level: .basic))

        XCTAssertEqual(_profile.lastSavedProfile?.languages.count, UserProfile.mock.languages.count + 1)
        XCTAssertEqual(_profile.lastSavedProfile?.firstName, UserProfile.mock.firstName)
        XCTAssertTrue(updated)
    }

    func test_deleteLanguageAction_removes() {
        DeleteProfileLanguageAction()(id: "lang-english")
        XCTAssertFalse(_profile.lastSavedProfile?.languages.contains { $0.id == "lang-english" } ?? true)
    }

    func test_saveNextRoleAction_updatesPreferences() {
        SaveNextRoleAction()(NextRolePreferences(availability: .immediately, salary: "$1", approachability: .notLooking))
        XCTAssertEqual(_profile.lastSavedProfile?.nextRole.availability, .immediately)
        XCTAssertEqual(_profile.lastSavedProfile?.nextRole.salary, "$1")
    }
}

@MainActor
final class SuggestedLanguageNamesServiceTests: AppTestCase {
    private let service = SuggestedLanguageNamesService()

    func test_prefixMatch_isCaseInsensitive() async {
        let results = await service.suggestions(for: "en").map(\.text)
        XCTAssertTrue(results.contains("English"))
        XCTAssertFalse(results.contains("French"))
    }

    func test_emptyQuery_returnsNothing() async {
        let results = await service.suggestions(for: "   ")
        XCTAssertTrue(results.isEmpty)
    }
}

@MainActor
private final class CaptureSuggestionsDelegate: ViewModelProviderDelegate {
    private(set) var models: [SuggestedLanguageNamesViewModel] = []
    func viewModelUpdated(_ viewModel: SuggestedLanguageNamesViewModel) { models.append(viewModel) }
}

@MainActor
final class SuggestedLanguageNamesViewModelProviderTests: AppTestCase {
    func test_valueChanged_pushesLoadingThenSuggestions() async {
        let provider = SuggestedLanguageNamesViewModelProvider()
        let capture = CaptureSuggestionsDelegate()
        let anyDelegate = AnyViewModelProviderDelegate(capture)
        provider.delegate = anyDelegate

        post(LanguageNameAutoSuggestEvents.ValueChanged(text: "en"))
        try? await Task.sleep(nanoseconds: 250_000_000)

        XCTAssertEqual(capture.models.first, .loading)
        if case .suggestions(let suggestions)? = capture.models.last {
            XCTAssertTrue(suggestions.contains { $0.text == "English" })
        } else {
            XCTFail("expected suggestions, got \(String(describing: capture.models.last))")
        }
    }
}
