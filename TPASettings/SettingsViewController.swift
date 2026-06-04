import UIKit
import TPAUIKit
import TPAFoundation

public final class SettingsViewController: StackContentViewController {

    public init() {
        let logoutRow = SettingsRowViewController(
            viewModel: .init(title: localize("settings.row.logout"), style: .destructive)
        )
        let rows: [Content] = [
            SettingsRowViewController(viewModel: .init(title: localize("settings.row.notifications"), style: .navigational)),
            SettingsRowViewController(viewModel: .init(title: localize("settings.row.privacy"), style: .navigational)),
            logoutRow
        ]

        super.init(content: rows, axis: .vertical, scrollable: true)

        logoutRow.onTap = { [weak self] in self?.handleLogout() }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = localize("settings.title")
        view.accessibilityIdentifier = "settings-view"
        post(SettingsEvents.Presented())
    }

    private func handleLogout() {
        @Resolved var logout: SettingsLogoutActionProtocol
        logout()
        dismiss(animated: true)
    }
}
