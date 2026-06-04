import UIKit
import TPAUIKit

final class ProfileSectionTabBarViewController: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        view.accessibilityIdentifier = "profile-tab-bar-home"
    }
}

extension ProfileSectionTabBarViewController: Content {
    func shouldAdd() -> Bool { true }
}
