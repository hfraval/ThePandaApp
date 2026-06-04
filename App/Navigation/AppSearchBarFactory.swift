import UIKit
import TPADiscovery
import TPASearch

@MainActor
final class AppSearchBarFactory: SearchBarFactory {
    func makeSearchBar() -> UIViewController {
        SearchBarViewController()
    }
}
