import UIKit
import TPACore
import TPAUIKit
import TPAFoundation

final class ProfileNextRoleSectionViewController: ProfileSectionViewController<NextRoleViewModel> {

    @Resolved private var saveNextRole: SaveNextRoleActionProtocol

    private let availabilityTitle = localize("profile.nextRole.availability.title")
    private let salaryTitle = localize("profile.nextRole.salary.title")
    private let approachabilityTitle = localize("profile.nextRole.approachability.title")

    private let availabilityRow = DisclosureRowView()
    private let salaryRow = DisclosureRowView()
    private let approachabilityRow = DisclosureRowView()

    private var current = NextRolePreferences.empty

    init() {
        super.init(sectionTitle: localize("profile.nextRole.title"))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func configureViews() {
        headerView.configure(title: localize("profile.nextRole.title"), actionTitle: nil)
        availabilityRow.onTap = { [weak self] in self?.editAvailability() }
        salaryRow.onTap = { [weak self] in self?.editSalary() }
        approachabilityRow.onTap = { [weak self] in self?.editApproachability() }

        let stack = VStack([headerView, availabilityRow, salaryRow, approachabilityRow])
        view.addSubviewFill(stack, insets: UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0))
    }

    override func render(viewModel: NextRoleViewModel) {
        current = viewModel.preferences
        let placeholder = localize("profile.nextRole.add")
        availabilityRow.configure(title: availabilityTitle, value: current.availability?.displayName, placeholder: placeholder)
        salaryRow.configure(title: salaryTitle, value: current.salary, placeholder: placeholder)
        approachabilityRow.configure(title: approachabilityTitle, value: current.approachability?.displayName, placeholder: placeholder)
    }

    private func editAvailability() {
        let options = Availability.allCases
        present(EditSelectionViewController(
            title: localize("profile.nextRole.availability.title"),
            options: options.map(\.displayName),
            selectedIndex: current.availability.flatMap { options.firstIndex(of: $0) }
        ) { [weak self] index in
            guard let self else { return }
            var preferences = self.current
            preferences.availability = options[index]
            self.saveNextRole(preferences)
        })
    }

    private func editApproachability() {
        let options = Approachability.allCases
        present(EditSelectionViewController(
            title: localize("profile.nextRole.approachability.title"),
            options: options.map(\.displayName),
            selectedIndex: current.approachability.flatMap { options.firstIndex(of: $0) }
        ) { [weak self] index in
            guard let self else { return }
            var preferences = self.current
            preferences.approachability = options[index]
            self.saveNextRole(preferences)
        })
    }

    private func editSalary() {
        present(EditSalaryViewController(initialValue: current.salary) { [weak self] value in
            guard let self else { return }
            var preferences = self.current
            preferences.salary = value
            self.saveNextRole(preferences)
        })
    }

    private func present(_ viewController: UIViewController) {
        present(UINavigationController(rootViewController: viewController), animated: true)
    }
}
