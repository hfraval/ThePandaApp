import TPACore

struct NextRoleViewModel: ProfileViewModel, Equatable {
    let preferences: NextRolePreferences

    static func make(profile: UserProfile?) -> NextRoleViewModel {
        NextRoleViewModel(preferences: profile?.nextRole ?? .empty)
    }
}
