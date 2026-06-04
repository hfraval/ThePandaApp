import UIKit
import TPAFoundation
import TPAUIKit

final class AppTabBarController: UITabBarController {

    init(discoveryNav: UINavigationController, profileNav: UINavigationController) {
        super.init(nibName: nil, bundle: nil)

        discoveryNav.tabBarItem = UITabBarItem(
            title: localize("tabs.discovery"),
            image: SystemIcon.safari.image,
            selectedImage: SystemIcon.safariFind.image
        )
        discoveryNav.tabBarItem.accessibilityIdentifier = "discovery-tab"

        profileNav.tabBarItem = UITabBarItem(
            title: localize("tabs.profile"),
            image: SystemIcon.person.image,
            selectedImage: SystemIcon.personFill.image
        )
        profileNav.tabBarItem.accessibilityIdentifier = "profile-tab"

        viewControllers = [discoveryNav, profileNav]
    }

    required init?(coder: NSCoder) { fatalError() }
}
