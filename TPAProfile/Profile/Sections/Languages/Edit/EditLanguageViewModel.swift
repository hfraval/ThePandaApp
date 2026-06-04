import Foundation
import TPACore
import TPAFoundation

struct EditLanguageViewModel {
    let languageProficiency: LanguageProficiency?
    let id: String

    init(languageProficiency: LanguageProficiency?) {
        self.languageProficiency = languageProficiency
        self.id = languageProficiency?.id ?? UUID().uuidString
    }

    var mode: ProfileEditMode { languageProficiency == nil ? .add : .edit }

    var viewTitle: String {
        localize(mode == .edit ? "profile.languages.edit.editTitle" : "profile.languages.edit.addTitle")
    }

    var showsDeleteButton: Bool { mode == .edit }
}
