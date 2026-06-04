import Foundation
import TPACore
import TPAFoundation
import TPAUIKit

@MainActor
public protocol ProfileViewModel {
    static func make(profile: UserProfile?) -> Self
}

@MainActor
class ProfileProvider {
    @Resolved private var profileService: ProfileServiceProtocol

    var profile: UserProfile? { profileService.profile }

    init() {
        TPAFoundation.observe(self, event: ProfileEvents.Updated.self, selector: #selector(profileUpdated))
    }

    func refresh() {
        Task { await profileService.refresh() }
    }

    @objc private func profileUpdated() {
        profileDidUpdate()
    }

    func profileDidUpdate() {}
}

@MainActor
final class ProfileViewModelProvider<ViewModel: ProfileViewModel>: ProfileProvider {
    private var _viewModel: ViewModel!

    weak var delegate: AnyViewModelProviderDelegate<ViewModel>? {
        didSet { delegate?.viewModelUpdated(viewModel) }
    }

    var viewModel: ViewModel { _viewModel }

    override init() {
        super.init()
        _viewModel = ViewModel.make(profile: profile)
    }

    override func profileDidUpdate() {
        _viewModel = ViewModel.make(profile: profile)
        delegate?.viewModelUpdated(viewModel)
    }
}
