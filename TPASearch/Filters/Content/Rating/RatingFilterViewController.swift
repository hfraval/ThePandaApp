import UIKit
import TPAUIKit
import TPAFoundation

final class RatingFilterViewController: UIViewController, CoordinatedContent {
    typealias ContentModel = SearchFiltersContentModel

    private let filterView = RatingFilterView()
    private var viewModel: RatingFilterViewModel

    init(query: SearchQuery) {
        viewModel = RatingFilterViewModel(query: query)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() { view = filterView }

    override func viewDidLoad() {
        super.viewDidLoad()
        filterView.stepper.addTarget(self, action: #selector(ratingChanged), for: .valueChanged)
        filterView.configure(with: viewModel)
    }

    @objc private func ratingChanged() {
        let value = filterView.stepper.value
        post(SearchFilterEvents.RatingDidUpdate(minimumRating: value > 0 ? value : nil))
    }

    func shouldAdd() -> Bool { true }
    func shouldShow(for model: SearchFiltersContentModel) -> Bool { true }

    func update(for model: SearchFiltersContentModel) -> CoordinatedContentUpdate? {
        viewModel = RatingFilterViewModel(query: model.query)
        return { [weak self] in
            guard let self else { return }
            self.filterView.configure(with: self.viewModel)
        }
    }
}
