import Foundation
import TPAUIKit

@MainActor
protocol SearchBarViewModelProviderProtocol: AnyObject {
    var delegate: AnyViewModelProviderDelegate<SearchBarViewModel>? { get set }
}

@MainActor
final class SearchBarViewModelProvider: SearchBarViewModelProviderProtocol {
    private let viewModelFactory: SearchBarViewModelFactory

    weak var delegate: AnyViewModelProviderDelegate<SearchBarViewModel>? {
        didSet { delegate?.viewModelUpdated(viewModelFactory.make()) }
    }

    init(viewModelFactory: SearchBarViewModelFactory = .init()) {
        self.viewModelFactory = viewModelFactory
    }
}
