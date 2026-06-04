import Foundation
import TPAFoundation

@MainActor
protocol SavePersonalDetailsActionProtocol {
    func callAsFunction(firstName: String, lastName: String, email: String)
}

@MainActor
final class SavePersonalDetailsAction: SavePersonalDetailsActionProtocol {
    @Resolved private var profileService: ProfileServiceProtocol

    init() {}

    func callAsFunction(firstName: String, lastName: String, email: String) {
        profileService.updatePersonalDetails(
            firstName: firstName.trimmed,
            lastName: lastName.trimmed,
            email: email.trimmed
        )
    }
}
