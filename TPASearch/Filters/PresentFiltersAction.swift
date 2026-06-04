import UIKit

@MainActor
protocol PresentFiltersActionProtocol {
    func callAsFunction(
        query: SearchQuery,
        from viewController: UIViewController,
        onApply: @escaping (SearchQuery) -> Void
    )
}

@MainActor
final class PresentFiltersAction: PresentFiltersActionProtocol {
    func callAsFunction(
        query: SearchQuery,
        from viewController: UIViewController,
        onApply: @escaping (SearchQuery) -> Void
    ) {
        let filters = SearchFiltersViewController(query: query, onApply: onApply)
        let nav = UINavigationController(rootViewController: filters)
        viewController.present(nav, animated: true)
    }
}
