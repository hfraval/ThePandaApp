import Foundation
import TPACore
import TPAFoundation

@MainActor
protocol SaveNextRoleActionProtocol {
    func callAsFunction(_ nextRole: NextRolePreferences)
}

@MainActor
final class SaveNextRoleAction: SaveNextRoleActionProtocol {
    @Resolved private var profileService: ProfileServiceProtocol

    init() {}

    func callAsFunction(_ nextRole: NextRolePreferences) {
        profileService.updateNextRole(nextRole)
    }
}
