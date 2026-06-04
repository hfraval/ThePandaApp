import Foundation
import TPAFoundation

struct ValidateLoginCommand: Sendable {
    func callAsFunction(email: String, password: String) -> Bool {
        email.isValidEmail && !password.trimmed.isEmpty && password.count >= 6
    }
}
