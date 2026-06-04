import Foundation
import TPAFoundation

struct PersonalDetailsValidation: Equatable {
    let firstNameError: String?
    let lastNameError: String?
    let emailError: String?

    var isValid: Bool {
        firstNameError == nil && lastNameError == nil && emailError == nil
    }
}

struct ValidatePersonalDetailsCommand {
    func callAsFunction(firstName: String, lastName: String, email: String) -> PersonalDetailsValidation {
        PersonalDetailsValidation(
            firstNameError: firstName.trimmed.isEmpty ? localize("validation.required") : nil,
            lastNameError: lastName.trimmed.isEmpty ? localize("validation.required") : nil,
            emailError: email.isValidEmail ? nil : localize("validation.invalidEmail")
        )
    }
}
