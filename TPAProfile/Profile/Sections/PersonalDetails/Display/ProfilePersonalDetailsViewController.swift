import UIKit
import TPAUIKit
import TPAFoundation

public final class ProfilePersonalDetailsViewController: UIViewController {
    private let detailsView = ProfilePersonalDetailsView()

    private let viewModelProvider: ProfileViewModelProvider<ProfilePersonalDetailsViewModel>
    private var anyViewModelProviderDelegate: AnyViewModelProviderDelegate<ProfilePersonalDetailsViewModel>?
    @Resolved private var loadAction: LoadProfileActionProtocol

    init(viewModelProvider: ProfileViewModelProvider<ProfilePersonalDetailsViewModel> = .init()) {
        self.viewModelProvider = viewModelProvider
        super.init(nibName: nil, bundle: nil)
        anyViewModelProviderDelegate = .init(self)
    }

    public convenience init() {
        self.init(viewModelProvider: .init())
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public func reload() {
        loadAction()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.primary

        view.addSubviewFill(detailsView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(editTapped))
        detailsView.addGestureRecognizer(tap)
        detailsView.isUserInteractionEnabled = true
        detailsView.accessibilityIdentifier = "profile-personal-details"
        detailsView.accessibilityTraits = .button

        detailsView.configure(with: viewModelProvider.viewModel)
        viewModelProvider.delegate = anyViewModelProviderDelegate
        loadAction()
    }

    @objc private func editTapped() {
        @Resolved var presentEdit: PresentEditPersonalDetailsActionProtocol
        presentEdit(from: self)
    }
}

extension ProfilePersonalDetailsViewController: ViewModelProviderDelegate {
    public func viewModelUpdated(_ viewModel: ProfilePersonalDetailsViewModel) {
        detailsView.configure(with: viewModel)
    }
}

extension ProfilePersonalDetailsViewController: Content {
    public func shouldAdd() -> Bool { true }
}
