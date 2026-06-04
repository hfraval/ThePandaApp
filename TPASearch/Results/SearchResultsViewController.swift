import UIKit
import TPAUIKit
import TPAFoundation

public final class SearchResultsViewController:
    CoordinatedStackContentViewController<SearchResultsContentModel>
{
    private var currentQuery: SearchQuery
    private let provider: SearchResultsContentModelProviderProtocol
    @Resolved private var runSearchAction: RunSearchActionProtocol
    private let errorChild: SearchResultsErrorViewController

    init(
        query: SearchQuery,
        provider: SearchResultsContentModelProviderProtocol = SearchResultsContentModelProvider()
    ) {
        self.currentQuery = query
        self.provider = provider

        let count = SearchResultsCountViewController()
        let list = SearchResultsListViewController()
        let empty = SearchResultsEmptyViewController()
        let loading = SearchResultsLoadingViewController()
        let error = SearchResultsErrorViewController()
        self.errorChild = error

        super.init(
            content: [
                AnyCoordinatedContent(count),
                AnyCoordinatedContent(list),
                AnyCoordinatedContent(empty),
                AnyCoordinatedContent(loading),
                AnyCoordinatedContent(error)
            ],
            axis: .vertical,
            scrollable: false
        )
    }

    public convenience init(query: SearchQuery) {
        self.init(query: query, provider: SearchResultsContentModelProvider())
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        title = localize("search.results.navigationTitle")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "slider.horizontal.3"),
            style: .plain,
            target: self,
            action: #selector(filtersTapped)
        )
        navigationItem.rightBarButtonItem?.accessibilityLabel = localize("search.filters.button")
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "search-filters-button"

        errorChild.onRetry = { [weak self] in
            guard let self else { return }
            self.runSearchAction(query: self.currentQuery)
        }

        provider.delegate = contentModelProviderDelegate
        runSearchAction(query: currentQuery)
    }

    @objc private func filtersTapped() {
        @Resolved var presentFilters: PresentFiltersActionProtocol
        presentFilters(query: currentQuery, from: self) { [weak self] newQuery in
            self?.currentQuery = newQuery
        }
    }
}
