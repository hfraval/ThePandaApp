import UIKit

public enum AppImageAsset: String {
    case brandLogo = "brand-logo"
}

public extension UIImage {
    static func asset(_ asset: AppImageAsset, bundle: Bundle = .main) -> UIImage {
        UIImage(named: asset.rawValue, in: bundle, compatibleWith: nil) ?? UIImage()
    }
}

public extension UIImageView {
    convenience init(asset: AppImageAsset) {
        self.init(image: .asset(asset))
    }
}
