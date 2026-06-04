import UIKit
import TPAFoundation
import TPADiscovery

@MainActor
final class RootController {
    private var window: UIWindow?
    private let bootStrapper = AppBootStrapper()

    func makeWindow(for scene: UIWindowScene) -> UIWindow {
        let w = UIWindow(windowScene: scene)
        self.window = w
        return w
    }

    func presentMainApp() {
        bootStrapper.startCritical()

        let discoveryNav = UINavigationController(rootViewController: DiscoveryViewController())
        let profileNav = UINavigationController(rootViewController: ProfileTabViewController())

        let tabBar = AppTabBarController(discoveryNav: discoveryNav, profileNav: profileNav)
        window?.rootViewController = tabBar
        window?.makeKeyAndVisible()

        bootStrapper.startDeferred()
    }

    func handleWarmStart() {
        bootStrapper.handleWarmStart()
    }
}
