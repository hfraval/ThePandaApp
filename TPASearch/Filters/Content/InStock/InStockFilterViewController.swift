import UIKit
import TPAUIKit
import TPAFoundation

final class InStockFilterViewController: UIViewController, CoordinatedContent {
    typealias ContentModel = SearchFiltersContentModel

    private let filterView = InStockFilterView()
    private var viewModel: InStockFilterViewModel

    init(query: SearchQuery) {
        viewModel = InStockFilterViewModel(query: query)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() { view = filterView }

    override func viewDidLoad() {
        super.viewDidLoad()
        filterView.toggle.addTarget(self, action: #selector(toggled), for: .valueChanged)
        filterView.configure(with: viewModel)
    }

    @objc private func toggled() {
        post(SearchFilterEvents.InStockDidUpdate(inStockOnly: filterView.toggle.isOn))
    }

    func shouldAdd() -> Bool { true }
    func shouldShow(for model: SearchFiltersContentModel) -> Bool { true }

    func update(for model: SearchFiltersContentModel) -> CoordinatedContentUpdate? {
        viewModel = InStockFilterViewModel(query: model.query)
        return { [weak self] in
            guard let self else { return }
            self.filterView.configure(with: self.viewModel)
        }
    }
}
