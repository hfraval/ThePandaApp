import XCTest

extension XCTestCase {
    var tabBar: AppTabBarElement { AppTabBarElement() }
    var loginScreen: LoginScreenElement { LoginScreenElement() }
    var discoveryScreen: DiscoveryScreenElement { DiscoveryScreenElement() }
    var searchResults: SearchResultsScreenElement { SearchResultsScreenElement() }
    var profileScreen: ProfileScreenElement { ProfileScreenElement() }
}
