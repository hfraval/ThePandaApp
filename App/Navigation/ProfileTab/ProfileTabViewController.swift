import UIKit
import SwiftUI
import TPAUIKit
import TPAAuth
import TPAProfile

final class ProfileTabViewController: CoordinatedStackContentViewController<ProfileTabContentModel> {
    private let provider = ProfileTabContentModelProvider()

    init() {
        let profileViewController = ProfileViewController()

        // Login is the SwiftUI pilot — a SwiftUI `LoginScreen` hosted via `HostingContent` so it
        // slots into the UIKit coordinated tab exactly like a UIKit child (see SWIFTUI_PILOT.md).
        let login = ClosureCoordinatedContent<HostingContent<LoginScreen>, ProfileTabContentModel>(
            HostingContent(LoginScreen()),
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
