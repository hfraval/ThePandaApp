import UIKit
import TPAUIKit
import TPAFoundation

final class PriceFilterViewController: UIViewController, CoordinatedContent {
    typealias ContentModel = SearchFiltersContentModel

    private let filterView = PriceFilterView()
    private var viewModel: PriceFilterViewModel

    init(query: SearchQuery) {
        viewModel = PriceFilterViewModel(query: query)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() { view = filterView }

    override func viewDidLoad() {
        super.viewDidLoad()
        filterView.slider.addTarget(self, action: #selector(priceChanged), for: .valueChanged)
        filterView.configure(with: viewModel)
    }

    @objc private func priceChanged() {
        let value = filterView.slider.value
        post(SearchFilterEvents.PriceDidUpdate(maxPrice: value > 0 ? Double(value) : nil))
    }

    func shouldAdd() -> Bool { true }
    func shouldShow(for model: SearchFiltersContentModel) -> Bool { true }

    func update(for model: SearchFiltersContentModel) -> CoordinatedContentUpdate? {
        viewModel = PriceFilterViewModel(query: model.query)
        return { [weak self] in
            guard let self else { return }
            self.filterView.configure(with: self.viewModel)
        }
    }
}
