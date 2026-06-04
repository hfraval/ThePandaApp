import UIKit
import TPAUIKit
import TPAFoundation

public final class SearchBarViewController: UIViewController {
    private let searchBarView = SearchBarView()
    private let viewModelProvider: SearchBarViewModelProviderProtocol
    private var anyViewModelProviderDelegate: AnyViewModelProviderDelegate<SearchBarViewModel>?

    init(viewModelProvider: SearchBarViewModelProviderProtocol = SearchBarViewModelProvider()) {
        self.viewModelProvider = viewModelProvider
        super.init(nibName: nil, bundle: nil)
        anyViewModelProviderDelegate = .init(self)
    }

    public convenience init() {
        self.init(viewModelProvider: SearchBarViewModelProvider())
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func loadView() {
        view = searchBarView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        searchBarView.searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        viewModelProvider.delegate = anyViewModelProviderDelegate
    }

    @objc private func searchTapped() {
        let query = SearchQuery(text: searchBarView.keywordsField.text ?? "")
        @Resolved var presentResults: PresentSearchResultsActionProtocol
        presentResults(query: query, from: self)
    }
}

extension SearchBarViewController: ViewModelProviderDelegate {
    public func viewModelUpdated(_ viewModel: SearchBarViewModel) {
        searchBarView.configure(with: viewModel)
    }
}

extension SearchBarViewController: Content {
    public func shouldAdd() -> Bool { true }
}
