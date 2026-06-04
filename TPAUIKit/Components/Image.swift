import UIKit

public final class Image: UIImageView {
    public init(_ image: UIImage?, tintColor: UIColor? = nil, contentMode: UIView.ContentMode = .scaleAspectFit) {
        super.init(image: image)
        if let tintColor { self.tintColor = tintColor }
        self.contentMode = contentMode
    }

    public convenience init(named name: String, tintColor: UIColor? = nil) {
        self.init(UIImage(named: name), tintColor: tintColor)
    }

    public convenience init(asset: AppImageAsset, tintColor: UIColor? = nil) {
        self.init(.asset(asset), tintColor: tintColor)
    }

    public convenience init(systemIcon: SystemIcon, tintColor: UIColor? = nil) {
        self.init(systemIcon.image, tintColor: tintColor)
    }

    public convenience init(systemName: String, tintColor: UIColor? = nil) {
        self.init(UIImage(systemName: systemName), tintColor: tintColor)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
