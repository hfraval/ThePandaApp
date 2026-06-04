import UIKit
import TPAUIKit
import TPAFoundation

final class SpacerSectionViewController: UIViewController, Content, ProfileFormSection {
    private let sectionHeight: CGFloat = 600

    let sectionTitle = localize("profile.spacer.title")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        view.heightAnchor.constraint(equalToConstant: sectionHeight).isActive = true
    }

    func shouldAdd() -> Bool { true }
    var sectionAnchor: UIView { view }
}
