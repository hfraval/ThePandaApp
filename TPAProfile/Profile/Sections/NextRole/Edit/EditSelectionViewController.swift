import UIKit
import TPAUIKit

final class EditSelectionViewController: UIViewController {

    private let options: [String]
    private let selectedIndex: Int?
    private let onSelect: (Int) -> Void
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(title: String, options: [String], selectedIndex: Int?, onSelect: @escaping (Int) -> Void) {
        self.options = options
        self.selectedIndex = selectedIndex
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() { view = tableView }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.accessibilityIdentifier = "selection-table"
    }

    @objc private func cancelTapped() { dismiss(animated: true) }
}

extension EditSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { options.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        cell.accessoryType = indexPath.row == selectedIndex ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelect(indexPath.row)
        dismiss(animated: true)
    }
}
