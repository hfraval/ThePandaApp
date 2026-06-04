import UIKit
import TPAUIKit
import TPAFoundation

final class SearchResultsErrorViewController: UIViewController, CoordinatedContent {
    typealias ContentModel = SearchResultsContentModel

    var onRetry: (() -> Void)?

    private let label = Label(typography: .body,
        textColor: AppColors.secondaryText,
        textAlignment: .center,
        numberOfLines: 0
    ).with {
        $0.text = localize("search.results.error.title") + "\n" + localize("search.results.error.subtitle")
    }

    private let retryButton = Button(text: localize("search.results.error.retry"), variant: .transparent).with {
        $0.accessibilityIdentifier = "search-results-retry"
    }

    private lazy var stack = VStack(spacing: 12, alignment: .center, [label, retryButton]).with {
        $0.accessibilityIdentifier = "search-results-error"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        view.addSubview(stack.withAutoLayout())
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    @objc private func retryTapped() { onRetry?() }

    func shouldAdd() -> Bool { true }

    func shouldShow(for model: SearchResultsContentModel) -> Bool {
        model == .failed
    }

    func update(for model: SearchResultsContentModel) -> CoordinatedContentUpdate? { nil }
}
