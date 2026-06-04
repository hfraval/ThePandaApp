import Foundation
import TPACore
import TPAFoundation
import TPALogging

@MainActor
public final class ProfileService: ProfileServiceProtocol {
    @Resolved private var sessionService: SessionServiceProtocol
    @Resolved private var localStorage: LocalStorageServiceProtocol
    @Resolved private var logger: LoggerProtocol
    private let storageKeyPrefix = "profile_"

    public private(set) var profile: UserProfile?

    public init() {}

    public func refresh() async {
        guard let userId = sessionService.currentUser?.id else { return }
        logger.info("Loading profile for user: \(userId)")
        try? await Task.sleep(nanoseconds: 150_000_000)

        profile = localStorage.load(UserProfile.self, forKey: key(userId))
            ?? UserProfile(userId: userId, firstName: "", lastName: "", email: "")
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
        localStorage.save(updated, forKey: key(updated.userId))
        post(ProfileEvents.Updated())
    }

    private func key(_ userId: String) -> String { storageKeyPrefix + userId }
}
