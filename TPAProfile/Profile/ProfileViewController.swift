import UIKit
import TPAUIKit
import TPAFoundation

public final class ProfileViewController: StackContentViewController, UIScrollViewDelegate {

    private let formView = ProfileFormView()

    private var ignoreScrolling = false

    public init() {
        super.init(
            content: [
                ProfilePersonalDetailsViewController(),
                ProfileSectionTabBarViewController(),
                ProfileLanguagesSectionViewController(),
                SpacerSectionViewController(),
                ProfileNextRoleSectionViewController()
            ],
            axis: .vertical,
            scrollable: true
        )
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override var contentView: StackContentView { formView }

    private var header: ProfilePersonalDetailsViewController? {
        content.compactMap { $0.viewController as? ProfilePersonalDetailsViewController }.first
    }
    private var tabBarHost: ProfileSectionTabBarViewController? {
        content.compactMap { $0.viewController as? ProfileSectionTabBarViewController }.first
    }

    private var sections: [ProfileFormSection] {
        content.compactMap { $0.viewController as? ProfileFormSection }
    }

    public func reload() {
        header?.reload()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        configureTabBar()
        formView.scrollView?.delegate = self
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationChrome()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clearNavigationChrome()
    }

    private func configureTabBar() {
        guard let tabBarHost else { return }

        formView.tabBar.setItems(sections.map(\.sectionTitle))
        formView.tabBar.onSelect = { [weak self] index in self?.scrollToSection(index) }

        formView.tabBar.removeFromSuperview()
        tabBarHost.view.addSubview(formView.tabBar)
        formView.tabBar.pinEdges(to: tabBarHost.view)
        tabBarHost.view.heightAnchor.constraint(equalTo: formView.tabBar.heightAnchor).isActive = true
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleDockingAndUndocking(scrollView)
        if !ignoreScrolling { syncSelectedTab(scrollView) }
    }

    private func handleDockingAndUndocking(_ scrollView: UIScrollView) {
        guard let tabBarHost else { return }
        let isDocked = formView.tabBar.isDescendant(of: formView.tabBarDock)
        let dockThreshold = tabBarHost.view.frame.minY

        if scrollView.contentOffset.y >= dockThreshold {
            guard !isDocked else { return }
            navigationItemForNavBar?.title = formView.tabBar.selectedTitle
            applyPrimaryNavigationBar(true, showsSeparator: true)
            moveTabBar(into: formView.tabBarDock)
            formView.bringSubviewToFront(formView.tabBarDock)
        } else {
            guard isDocked, let tabBarHost = self.tabBarHost else { return }
            navigationItemForNavBar?.title = nil
            applyPrimaryNavigationBar(true, showsSeparator: false)
            moveTabBar(into: tabBarHost.view)
            formView.sendSubviewToBack(formView.tabBarDock)
        }
    }

    private func moveTabBar(into container: UIView) {
        formView.tabBar.removeFromSuperview()
        container.addSubview(formView.tabBar)
        formView.tabBar.pinEdges(to: container)
    }

    private func syncSelectedTab(_ scrollView: UIScrollView) {
        guard formView.tabBar.isDescendant(of: formView.tabBarDock) else { return }
        let referenceY = scrollView.contentOffset.y + formView.tabBar.frame.height
        for (index, section) in sections.enumerated() {
            let anchor = section.sectionAnchor
            let minY = formView.stackView.convert(anchor.bounds, from: anchor).minY
            if referenceY >= minY { formView.tabBar.selectedIndex = index }
        }
    }

    private func scrollToSection(_ index: Int) {
        let sections = self.sections
        guard let scrollView = formView.scrollView, sections.indices.contains(index) else { return }

        let anchor = sections[index].sectionAnchor
        let sectionTop = formView.stackView.convert(anchor.bounds, from: anchor).minY - formView.tabBar.frame.height
        let maxOffset = max(0, scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom)
        let target = min(max(0, sectionTop), maxOffset)

        ignoreScrolling = true
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            scrollView.contentOffset.y = target
        }, completion: { [weak self] _ in
            self?.ignoreScrolling = false
        })
    }

    private var navigationItemForNavBar: UINavigationItem? {
        navigationController?.topViewController?.navigationItem
    }

    private func configureNavigationChrome() {
        applyPrimaryNavigationBar(true)
        guard let navItem = navigationItemForNavBar else { return }

        let settingsItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsTapped)
        )
        settingsItem.accessibilityLabel = localize("profile.button.settings")
        settingsItem.accessibilityIdentifier = "settings-button"
        navItem.rightBarButtonItem = settingsItem
        navItem.leftBarButtonItem = nil
        navItem.title = nil
    }

    private func clearNavigationChrome() {
        guard let navItem = navigationItemForNavBar else { return }
        navItem.leftBarButtonItem = nil
        navItem.rightBarButtonItem = nil
        navItem.title = nil
        applyPrimaryNavigationBar(false)
    }

    private func applyPrimaryNavigationBar(_ primary: Bool, showsSeparator: Bool = false) {
        guard let navigationBar = navigationController?.navigationBar else { return }
        let appearance = UINavigationBarAppearance()
        if primary {
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = AppColors.primary
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.shadowColor = showsSeparator ? UIColor.black.withAlphaComponent(0.15) : .clear
            navigationBar.tintColor = .white
        } else {
            appearance.configureWithDefaultBackground()
            navigationBar.tintColor = nil
        }
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }

    @objc private func settingsTapped() {
        @Resolved var presentSettings: PresentSettingsActionProtocol
        presentSettings(from: self)
    }
}

extension ProfileViewController: Content {
    public func shouldAdd() -> Bool { true }
}
