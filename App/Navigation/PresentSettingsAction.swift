import UIKit
import TPAProfile
import TPASettings

@MainActor
final class PresentSettingsAction: PresentSettingsActionProtocol {
    func callAsFunction(from viewController: UIViewController) {
        let settings = SettingsViewController()
        let nav = UINavigationController(rootViewController: settings)
        viewController.present(nav, animated: true)
    }
}
