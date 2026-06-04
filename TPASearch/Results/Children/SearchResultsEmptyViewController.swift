import UIKit
import TPAUIKit
import TPAFoundation

final class SearchResultsEmptyViewController: UIViewController, CoordinatedContent {
    typealias ContentModel = SearchResultsContentModel

    private let label = Label(typography: .body,
        textColor: AppColors.secondaryText,
        textAlignment: .center,
        numberOfLines: 0
    ).with {
        $0.text = localize("search.results.empty.title") + "\n" + localize("search.results.empty.subtitle")
        $0.accessibilityIdentifier = "search-results-empty"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label.withAutoLayout())
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    func shouldAdd() -> Bool { true }

    func shouldShow(for model: SearchResultsContentModel) -> Bool {
        model == .empty
    }

    func update(for model: SearchResultsContentModel) -> CoordinatedContentUpdate? { nil }
}
