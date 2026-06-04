import UIKit
import TPADiscovery
import TPAProfile
import TPASearch
import TPASettings

@MainActor
public final class TestSearchBarFactory: SearchBarFactory {
    public init() {}
    public func makeSearchBar() -> UIViewController { SearchBarViewController() }
}

@MainActor
public final class TestPresentSettingsAction: PresentSettingsActionProtocol {
    public init() {}
    public func callAsFunction(from viewController: UIViewController) {
        let nav = UINavigationController(rootViewController: SettingsViewController())
        viewController.present(nav, animated: true)
    }
}
