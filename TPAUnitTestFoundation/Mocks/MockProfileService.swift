import Foundation
import TPACore
import TPAFoundation
import TPAProfile

@MainActor
public final class MockProfileService: ProfileServiceProtocol {
    public var profile: UserProfile?

    public private(set) var refreshCallCount = 0
    public private(set) var lastSavedProfile: UserProfile?

    public init() {}

    public func refresh() async {
        refreshCallCount += 1
        post(ProfileEvents.Updated())
    }

    public func updatePersonalDetails(firstName: String, lastName: String, email: String) {
        mutate {
            $0.firstName = firstName
            $0.lastName = lastName
            $0.email = email
        }
    }

    public func updateLanguage(_ language: LanguageProficiency) {
        mutate { profile in
            if let index = profile.languages.firstIndex(where: { $0.id == language.id }) {
                profile.languages[index] = language
            } else {
                profile.languages.append(language)
            }
        }
    }

    public func deleteLanguage(id: String) {
        mutate { $0.languages.removeAll { $0.id == id } }
    }

    public func updateNextRole(_ nextRole: NextRolePreferences) {
        mutate { $0.nextRole = nextRole }
    }

    private func mutate(_ block: (inout UserProfile) -> Void) {
        guard var updated = profile else { return }
        block(&updated)
        profile = updated
        lastSavedProfile = updated
        post(ProfileEvents.Updated())
    }
}
