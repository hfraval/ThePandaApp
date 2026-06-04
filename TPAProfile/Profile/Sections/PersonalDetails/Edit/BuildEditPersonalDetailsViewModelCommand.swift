import Foundation
import TPAFoundation

@MainActor
struct BuildEditPersonalDetailsViewModelCommand {
    func callAsFunction() -> EditPersonalDetailsViewModel {
        @Resolved var profileService: ProfileServiceProtocol
        let profile = profileService.profile

        return EditPersonalDetailsViewModel(
            firstName: profile?.firstName ?? "",
            lastName: profile?.lastName ?? "",
            email: profile?.email ?? ""
        )
    }
}
