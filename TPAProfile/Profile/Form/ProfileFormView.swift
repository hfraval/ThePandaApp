import UIKit
import TPAUIKit

final class ProfileFormView: StackContentView {

    let tabBarDock: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.background
        return v
    }()

    let tabBar = ProfileSectionTabBar()

    init() {
        super.init(axis: .vertical, scrollable: true, spacing: 0)
        addSubview(tabBarDock)
        NSLayoutConstraint.activate([
            tabBarDock.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tabBarDock.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabBarDock.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
