import UIKit
import TPAUIKit

final class SettingsRowViewController: UIViewController {
    private let rowView = SettingsRowView()
    private let viewModel: SettingsRowViewModel

    var onTap: (() -> Void)?

    init(viewModel: SettingsRowViewModel, onTap: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onTap = onTap
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        view = rowView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        rowView.configure(with: viewModel)
        rowView.button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    @objc private func tapped() {
        onTap?()
    }
}

extension SettingsRowViewController: Content {
    func shouldAdd() -> Bool { true }
}
