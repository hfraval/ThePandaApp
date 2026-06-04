import Foundation
import TPACore
import TPAFoundation

@MainActor
protocol SaveProfileLanguageActionProtocol {
    func callAsFunction(for language: LanguageProficiency)
}

@MainActor
final class SaveProfileLanguageAction: SaveProfileLanguageActionProtocol {
    @Resolved private var profileService: ProfileServiceProtocol

    init() {}

    func callAsFunction(for language: LanguageProficiency) {
        profileService.updateLanguage(language)
    }
}

@MainActor
protocol DeleteProfileLanguageActionProtocol {
    func callAsFunction(id: String)
}

@MainActor
final class DeleteProfileLanguageAction: DeleteProfileLanguageActionProtocol {
    @Resolved private var profileService: ProfileServiceProtocol

    init() {}

    func callAsFunction(id: String) {
        profileService.deleteLanguage(id: id)
    }
}
