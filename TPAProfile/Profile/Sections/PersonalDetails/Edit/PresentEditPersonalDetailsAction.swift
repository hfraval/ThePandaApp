import UIKit
import TPAUIKit

@MainActor
protocol PresentEditPersonalDetailsActionProtocol {
    func callAsFunction(from viewController: UIViewController)
}

@MainActor
final class PresentEditPersonalDetailsAction: PresentEditPersonalDetailsActionProtocol {
    func callAsFunction(from viewController: UIViewController) {
        let editViewController = EditPersonalDetailsViewController()
        viewController.present(editViewController.wrapInModalNavigationController(closeDelegate: editViewController), animated: true)
    }
}
