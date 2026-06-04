import UIKit

public extension UIEdgeInsets {
    static func with(
        top: CGFloat = 0,
        left: CGFloat = 0,
        bottom: CGFloat = 0,
        right: CGFloat = 0,
        horizontal: CGFloat = 0,
        vertical: CGFloat = 0,
        all: CGFloat = 0
    ) -> UIEdgeInsets {
        UIEdgeInsets(
            top: all + vertical + top,
            left: all + horizontal + left,
            bottom: all + vertical + bottom,
            right: all + horizontal + right
        )
    }
}
