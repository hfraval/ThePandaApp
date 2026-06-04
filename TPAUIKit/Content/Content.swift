import UIKit

@MainActor
public protocol Content {
    func shouldAdd() -> Bool
    var viewController: UIViewController { get }
}

public extension Content where Self: UIViewController {
    var viewController: UIViewController { self }

    func show() {
        guard view.isHidden else { return }
        beginAppearanceTransition(true, animated: false)
        view.isHidden = false
        endAppearanceTransition()
    }

    func hide() {
        guard !view.isHidden else { return }
        beginAppearanceTransition(false, animated: false)
        view.isHidden = true
        endAppearanceTransition()
    }
}
