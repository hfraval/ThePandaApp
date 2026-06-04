import UIKit
import TPAUIKit
import TPAFoundation

final class BrandFilterViewController: UIViewController, CoordinatedContent {
    typealias ContentModel = SearchFiltersContentModel

    private let filterView = BrandFilterView()
    private var viewModel: BrandFilterViewModel

    init(query: SearchQuery) {
        viewModel = BrandFilterViewModel(query: query)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() { view = filterView }

    override func viewDidLoad() {
        super.viewDidLoad()
        filterView.field.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        filterView.configure(with: viewModel)
    }

    @objc private func textChanged() {
        let trimmed = (filterView.field.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        post(SearchFilterEvents.BrandDidUpdate(brand: trimmed.isEmpty ? nil : trimmed))
    }

    func shouldAdd() -> Bool { true }
    func shouldShow(for model: SearchFiltersContentModel) -> Bool { true }

    func update(for model: SearchFiltersContentModel) -> CoordinatedContentUpdate? {
        viewModel = BrandFilterViewModel(query: model.query)
        return { [weak self] in
            guard let self else { return }
            self.filterView.configure(with: self.viewModel)
        }
    }
}
