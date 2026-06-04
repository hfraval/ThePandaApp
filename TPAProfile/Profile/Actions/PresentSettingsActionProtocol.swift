import UIKit

@MainActor
public protocol PresentSettingsActionProtocol {
    func callAsFunction(from viewController: UIViewController)
}
