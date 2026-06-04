import Foundation
import TPAFoundation

@MainActor
protocol LoginActionProtocol {
    func callAsFunction(email: String, password: String)
}

@MainActor
final class LoginAction: LoginActionProtocol {
    @Resolved private var service: LoginServiceProtocol

    init() {}

    func callAsFunction(email: String, password: String) {
        guard ValidateLoginCommand()(email: email, password: password) else { return }
        Task { await service.login(email: email, password: password) }
    }
}
