import UIKit
import TPAUIKit
import TPAAuth
import TPAProfile

final class ProfileTabViewController: CoordinatedStackContentViewController<ProfileTabContentModel> {
    private let provider = ProfileTabContentModelProvider()

    init() {
        let profileViewController = ProfileViewController()

        let login = ClosureCoordinatedContent<LoginViewController, ProfileTabContentModel>(
            LoginViewController(),
            shouldShow: { !$0.isSignedIn }
        )
        let profile = ClosureCoordinatedContent<ProfileViewController, ProfileTabContentModel>(
            profileViewController,
            shouldShow: { $0.isSignedIn },
            update: { vc, model in
                guard model.isSignedIn else { return nil }
                return { vc.reload() }
            }
        )

        super.init(
            content: [
                AnyCoordinatedContent(login),
                AnyCoordinatedContent(profile)
            ],
            axis: .vertical,
            scrollable: false
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "profile-tab-view"
        provider.delegate = contentModelProviderDelegate
    }
}
