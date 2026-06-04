import UIKit
import TPAUIKit
import TPAFoundation

final class SearchResultsLoadingViewController: UIViewController, CoordinatedContent {
    typealias ContentModel = SearchResultsContentModel

    private let loadingView = LoadingView()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.message = localize("search.results.loading")
        view.addSubviewFill(loadingView)
    }

    func shouldAdd() -> Bool { true }

    func shouldShow(for model: SearchResultsContentModel) -> Bool {
        model == .loading
    }

    func update(for model: SearchResultsContentModel) -> CoordinatedContentUpdate? {
        let isLoading = model == .loading
        return { [weak self] in
            isLoading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
        }
    }
}
