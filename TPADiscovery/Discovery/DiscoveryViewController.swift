import UIKit
import TPAUIKit
import TPAFoundation

public final class DiscoveryViewController: UIViewController {
    private let discoveryView = DiscoveryView()
    @Resolved private var searchBarFactory: SearchBarFactory
    private lazy var searchBarViewController = searchBarFactory.makeSearchBar()

    private var viewModelProvider: DiscoveryViewModelProviderProtocol
    private var anyViewModelProviderDelegate: AnyViewModelProviderDelegate<DiscoveryViewModel>?

    init(viewModelProvider: DiscoveryViewModelProviderProtocol = DiscoveryViewModelProvider()) {
        self.viewModelProvider = viewModelProvider
        super.init(nibName: nil, bundle: nil)
        anyViewModelProviderDelegate = .init(self)
    }

    public convenience init() {
        self.init(viewModelProvider: DiscoveryViewModelProvider())
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupLayout()
        viewModelProvider.delegate = anyViewModelProviderDelegate
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        post(DiscoveryEvents.Appeared())
    }

    private func setupLayout() {
        add(child: searchBarViewController)
        let searchBar = searchBarViewController.view.withAutoLayout()
        view.addSubview(searchBar)
        view.addSubview(discoveryView.withAutoLayout())

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            discoveryView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            discoveryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            discoveryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            discoveryView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension DiscoveryViewController: ViewModelProviderDelegate {
    public func viewModelUpdated(_ viewModel: DiscoveryViewModel) {
        title = viewModel.navigationTitle
        discoveryView.configure(with: viewModel)
    }
}

extension DiscoveryViewController: Content {
    public func shouldAdd() -> Bool { true }
}
