import UIKit

@MainActor
public protocol SearchBarFactory {
    func makeSearchBar() -> UIViewController
}
