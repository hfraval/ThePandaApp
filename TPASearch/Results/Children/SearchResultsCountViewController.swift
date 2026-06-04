import UIKit
import TPAUIKit
import TPAFoundation

final class SearchResultsCountViewController: UIViewController, CoordinatedContent {
    typealias ContentModel = SearchResultsContentModel

    private static let height: CGFloat = 36

    private let label = Label(typography: .footnote,
        textColor: AppColors.secondaryText,
        textAlignment: .center
    ).with {
        $0.accessibilityIdentifier = "search-results-count"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviewFill(label)
        view.heightAnchor.constraint(equalToConstant: Self.height).isActive = true
    }

    func shouldAdd() -> Bool { true }

    func shouldShow(for model: SearchResultsContentModel) -> Bool {
        if case .results = model { return true }
        return false
    }

    func update(for model: SearchResultsContentModel) -> CoordinatedContentUpdate? {
        guard case .results(let items) = model else { return nil }
        return { [weak self] in
            self?.label.text = String(format: localize("search.results.count"), items.count)
        }
    }
}
