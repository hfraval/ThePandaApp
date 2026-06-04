import UIKit

public extension UIViewController {
    func add(child: UIViewController, to containerView: UIView, insets: UIEdgeInsets = .zero, safeArea: Bool = false) {
        addChild(child)
        containerView.addSubviewFill(child.view, insets: insets, safeArea: safeArea)
        child.didMove(toParent: self)
    }

    func add(child: UIViewController) {
        addChild(child)
        child.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else { return }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
