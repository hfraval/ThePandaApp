import UIKit

@MainActor
protocol PresentSearchResultsActionProtocol {
    func callAsFunction(query: SearchQuery, from viewController: UIViewController)
}

@MainActor
final class PresentSearchResultsAction: PresentSearchResultsActionProtocol {
    func callAsFunction(query: SearchQuery, from viewController: UIViewController) {
        let resultsViewController = SearchResultsViewController(query: query)
        viewController.navigationController?.pushViewController(resultsViewController, animated: true)
    }
}
