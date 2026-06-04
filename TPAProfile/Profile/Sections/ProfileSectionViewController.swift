import UIKit
import TPACore
import TPAUIKit

@MainActor
protocol ProfileFormSection: AnyObject {
    var sectionTitle: String { get }
    var sectionAnchor: UIView { get }
}

@MainActor
class ProfileSectionViewController<ViewModel: ProfileViewModel>:
    UIViewController, Content, ProfileFormSection, ViewModelProviderDelegate
{
    let sectionTitle: String
    let headerView = ProfileSectionHeaderView()
    let viewModelProvider: ProfileViewModelProvider<ViewModel>
    private var anyViewModelProviderDelegate: AnyViewModelProviderDelegate<ViewModel>?

    init(
        sectionTitle: String,
        viewModelProvider: ProfileViewModelProvider<ViewModel> = .init()
    ) {
        self.sectionTitle = sectionTitle
        self.viewModelProvider = viewModelProvider
        super.init(nibName: nil, bundle: nil)
        anyViewModelProviderDelegate = .init(self)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        configureViews()
        render(viewModel: viewModelProvider.viewModel)
        viewModelProvider.delegate = anyViewModelProviderDelegate
    }

    func configureViews() {}

    func render(viewModel: ViewModel) {}

    func viewModelUpdated(_ viewModel: ViewModel) {
        render(viewModel: viewModel)
    }

    func shouldAdd() -> Bool { true }
    var sectionAnchor: UIView { view }
}
