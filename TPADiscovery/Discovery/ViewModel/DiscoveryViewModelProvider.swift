import Foundation
import TPAUIKit

@MainActor
protocol DiscoveryViewModelProviderProtocol: AnyObject {
    var delegate: AnyViewModelProviderDelegate<DiscoveryViewModel>? { get set }
}

@MainActor
final class DiscoveryViewModelProvider: DiscoveryViewModelProviderProtocol {
    private let viewModelFactory: DiscoveryViewModelFactory

    weak var delegate: AnyViewModelProviderDelegate<DiscoveryViewModel>? {
        didSet { updateDelegate() }
    }

    init(viewModelFactory: DiscoveryViewModelFactory = .init()) {
        self.viewModelFactory = viewModelFactory
    }

    private func updateDelegate() {
        delegate?.viewModelUpdated(viewModelFactory.make())
    }
}
