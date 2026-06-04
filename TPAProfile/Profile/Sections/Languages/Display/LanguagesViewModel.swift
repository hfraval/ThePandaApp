import TPACore

struct LanguagesViewModel: ProfileViewModel, Equatable {
    let languages: [LanguageProficiency]

    static func make(profile: UserProfile?) -> LanguagesViewModel {
        LanguagesViewModel(languages: profile?.languages ?? [])
    }
}
