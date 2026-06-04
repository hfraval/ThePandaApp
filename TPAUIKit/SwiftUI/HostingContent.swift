import SwiftUI

/// A `UIHostingController` that conforms to `Content`, so a SwiftUI screen can be dropped into our
/// UIKit composition (a `StackContentViewController` or a `ClosureCoordinatedContent`) exactly like
/// a UIKit child view controller. This is the UIKit↔SwiftUI seam.
@MainActor
public final class HostingContent<RootView: View>: UIHostingController<RootView>, Content {
    public init(_ rootView: RootView) {
        super.init(rootView: rootView)
        view.backgroundColor = .clear
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func shouldAdd() -> Bool { true }
}
