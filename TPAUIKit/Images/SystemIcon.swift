import UIKit

public enum SystemIcon: String {
    case safari
    case safariFind = "safari.fill"
    case person
    case personFill = "person.fill"
    case settings = "gear"
    case settingsFill = "gear.fill"
    case checkmark
    case xmark
    case error = "exclamationmark.circle.fill"
    case eyeOff = "eye.slash.fill"
    case eye = "eye.fill"
    case lock
    case envelope

    public var image: UIImage {
        UIImage(systemName: rawValue) ?? UIImage()
    }
}

public extension UIImage {
    static func systemIcon(_ icon: SystemIcon, size: CGFloat = 24) -> UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: size, weight: .regular, scale: .default)
        return (icon.image.withConfiguration(config)) ?? UIImage()
    }
}
