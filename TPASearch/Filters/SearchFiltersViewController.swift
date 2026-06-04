import UIKit
import TPAUIKit
import TPAFoundation

final class SearchFiltersViewController: CoordinatedStackContentViewController<SearchFiltersContentModel> {

    private let initialQuery: SearchQuery
    private let onApply: (SearchQuery) -> Void
    private let provider: SearchFiltersContentModelProvider

    private let applyButton = Button(text: localize("search.filters.apply"), variant: .solid).with {
        $0.accessibilityIdentifier = "filters-apply"
    }

    init(query: SearchQuery, onApply: @escaping (SearchQuery) -> Void = { _ in }) {
        self.initialQuery = query
        self.onApply = onApply
        self.provider = SearchFiltersContentModelProvider(query: query)
        super.init(
            content: [
                AnyCoordinatedContent(CategoryFilterViewController(query: query)),
                AnyCoordinatedContent(SortByFilterViewController(query: query)),
                AnyCoordinatedContent(PriceFilterViewController(query: query)),
                AnyCoordinatedContent(RatingFilterViewController(query: query)),
                AnyCoordinatedContent(InStockFilterViewController(query: query)),
                AnyCoordinatedContent(BrandFilterViewController(query: query))
            ],
            axis: .vertical,
            scrollable: true,
            spacing: 12
        )
    }

    convenience init(query: SearchQuery) {
        self.init(query: query, onApply: { _ in })
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        title = localize("search.filters.title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: localize("search.filters.reset"), style: .plain, target: self, action: #selector(resetTapped)
        )

        installStickyApplyButton()
        applyButton.action = { [weak self] in self?.apply() }
        provider.delegate = contentModelProviderDelegate
    }

    private func installStickyApplyButton() {
        view.addSubview(applyButton.withAutoLayout())
        NSLayoutConstraint.activate([
            applyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
        contentView.scrollView?.contentInset.bottom = 72
        contentView.scrollView?.verticalScrollIndicatorInsets.bottom = 72
    }

    @objc private func resetTapped() {
        provider.query = SearchQuery(text: initialQuery.text, category: initialQuery.category)
    }

    private func apply() {
        let query = provider.query
        onApply(query)
        @Resolved var runSearch: RunSearchActionProtocol
        runSearch(query: query)
        dismiss(animated: true)
    }
}
