import Foundation
import TPACore
import TPAFoundation

public struct ProfilePersonalDetailsViewModel: ProfileViewModel, Equatable {
    let displayName: String
    let name: String
    let firstName: String
    let lastName: String
    let email: String
    let displayEmail: String
    let showEmail: Bool

    public static func make(profile: UserProfile?) -> ProfilePersonalDetailsViewModel {
        let firstName = profile?.firstName ?? ""
        let lastName = profile?.lastName ?? ""
        let email = profile?.email ?? ""
        let fullName = profile?.fullName ?? ""
        return ProfilePersonalDetailsViewModel(
            displayName: fullName.isEmpty ? localize("profile.header.namePlaceholder") : fullName,
            name: fullName,
            firstName: firstName,
            lastName: lastName,
            email: email,
            displayEmail: email.isEmpty ? localize("profile.header.emailPlaceholder") : email,
            showEmail: !email.isEmpty
        )
    }
}
