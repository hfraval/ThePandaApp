import Foundation
import TPACore

@MainActor
public protocol ProfileServiceProtocol: AnyObject {
    var profile: UserProfile? { get }

    func refresh() async

    func updatePersonalDetails(firstName: String, lastName: String, email: String)
    func updateLanguage(_ language: LanguageProficiency)
    func deleteLanguage(id: String)
    func updateNextRole(_ nextRole: NextRolePreferences)
}
