import Foundation
import TPACore
import TPAFoundation

@MainActor
protocol SettingsLogoutActionProtocol {
    func callAsFunction()
}

@MainActor
final class SettingsLogoutAction: SettingsLogoutActionProtocol {
    @Resolved private var sessionService: SessionServiceProtocol

    func callAsFunction() {
        sessionService.clearSession()
        post(AuthEvents.SignedOut())
    }
}
