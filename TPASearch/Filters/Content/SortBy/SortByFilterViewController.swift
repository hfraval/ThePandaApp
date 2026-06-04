import UIKit
import TPAUIKit
import TPAFoundation

final class SortByFilterViewController: UIViewController, CoordinatedContent {
    typealias ContentModel = SearchFiltersContentModel

    private let filterView = SortByFilterView()
    private var viewModel: SortByFilterViewModel

    init(query: SearchQuery) {
        viewModel = SortByFilterViewModel(query: query)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() { view = filterView }

    override func viewDidLoad() {
        super.viewDidLoad()
        filterView.control.addTarget(self, action: #selector(sortChanged), for: .valueChanged)
        filterView.configure(with: viewModel)
    }

    @objc private func sortChanged() {
        let sortBy: SearchQuery.SortField?
        switch filterView.control.selectedSegmentIndex {
        case 1: sortBy = .title
        case 2: sortBy = .price
        case 3: sortBy = .rating
        default: sortBy = nil
        }
        post(SearchFilterEvents.SortByDidUpdate(sortBy: sortBy))
    }

    func shouldAdd() -> Bool { true }
    func shouldShow(for model: SearchFiltersContentModel) -> Bool { true }

    func update(for model: SearchFiltersContentModel) -> CoordinatedContentUpdate? {
        viewModel = SortByFilterViewModel(query: model.query)
        return { [weak self] in
            guard let self else { return }
            self.filterView.configure(with: self.viewModel)
        }
    }
}
