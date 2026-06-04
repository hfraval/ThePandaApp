import UIKit
import TPAUIKit

final class ProfileSectionTabBar: UIView {

    private let segmentedControl = UISegmentedControl()
    private let separator = UIView()

    var onSelect: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AppColors.background
        accessibilityIdentifier = "profile-tab-bar"

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(selectionChanged), for: .valueChanged)

        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = AppColors.separator

        addSubviews(segmentedControl, separator)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            segmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -9),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setItems(_ titles: [String]) {
        segmentedControl.removeAllSegments()
        for (index, title) in titles.enumerated() {
            segmentedControl.insertSegment(withTitle: title, at: index, animated: false)
        }
        if !titles.isEmpty { segmentedControl.selectedSegmentIndex = 0 }
    }

    var selectedIndex: Int {
        get { segmentedControl.selectedSegmentIndex }
        set { if segmentedControl.selectedSegmentIndex != newValue { segmentedControl.selectedSegmentIndex = newValue } }
    }

    var selectedTitle: String? {
        guard segmentedControl.selectedSegmentIndex >= 0 else { return nil }
        return segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
    }

    @objc private func selectionChanged() {
        onSelect?(segmentedControl.selectedSegmentIndex)
    }
}
