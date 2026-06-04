import Foundation
import TPAFoundation

struct DiscoveryViewModelFactory {
    func make() -> DiscoveryViewModel {
        DiscoveryViewModel(
            navigationTitle: localize("tabs.discovery"),
            title: localize("discovery.underConstruction.title"),
            subtitle: localize("discovery.underConstruction.subtitle")
        )
    }
}
