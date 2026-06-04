import UIKit

@MainActor
@objc public protocol ModalCloseDelegate: AnyObject {
    @objc func didTapCloseButton()
}

public extension UIViewController {
    func wrapInModalNavigationController(closeDelegate: ModalCloseDelegate? = nil) -> UINavigationController {
        let target: Any = closeDelegate ?? self
        let action = closeDelegate != nil
            ? #selector(ModalCloseDelegate.didTapCloseButton)
            : #selector(dismissModal)

        let closeItem = UIBarButtonItem(barButtonSystemItem: .close, target: target, action: action)
        closeItem.accessibilityIdentifier = "close-button"
        navigationItem.leftBarButtonItem = closeItem

        return UINavigationController(rootViewController: self)
    }

    @objc func dismissModal() {
        view.endEditing(true)
        dismiss(animated: true)
    }
}
