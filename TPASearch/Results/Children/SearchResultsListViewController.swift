import UIKit
import TPAUIKit

final class SearchResultsListViewController: UIViewController, CoordinatedContent {
    typealias ContentModel = SearchResultsContentModel

    private let tableView = UITableView(frame: .zero, style: .plain).with {
        $0.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.reuseID)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 84
        $0.allowsSelection = false
        $0.accessibilityIdentifier = "search-results-table"
    }

    private var items: [SearchResultItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.pinEdges(to: view)
    }

    func shouldAdd() -> Bool { true }

    func shouldShow(for model: SearchResultsContentModel) -> Bool {
        if case .results = model { return true }
        return false
    }

    func update(for model: SearchResultsContentModel) -> CoordinatedContentUpdate? {
        guard case .results(let newItems) = model else { return nil }
        return { [weak self] in
            guard let self else { return }
            self.items = newItems
            self.tableView.reloadData()
        }
    }
}

extension SearchResultsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.reuseID, for: indexPath)
        if let cell = cell as? SearchResultCell, let item = items[safe: indexPath.row] {
            cell.configure(with: item)
        }
        return cell
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
