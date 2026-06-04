import UIKit

public extension UIImageView {
    private static let cache = NSCache<NSURL, UIImage>()

    func setRemoteImage(_ url: URL?, placeholder: UIImage? = nil) {
        image = placeholder
        guard let url else { return }

        if let cached = Self.cache.object(forKey: url as NSURL) {
            image = cached
            return
        }

        let token = UUID()
        currentImageToken = token

        Task { [weak self] in
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let loaded = UIImage(data: data) else { return }
            Self.cache.setObject(loaded, forKey: url as NSURL)
            await MainActor.run {
                guard let self, self.currentImageToken == token else { return }
                self.image = loaded
            }
        }
    }
}

private extension UIImageView {
    private static var tokenKey: UInt8 = 0
    var currentImageToken: UUID? {
        get { objc_getAssociatedObject(self, &Self.tokenKey) as? UUID }
        set { objc_setAssociatedObject(self, &Self.tokenKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
