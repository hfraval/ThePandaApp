import Foundation

public protocol With {}

public extension With {
    @discardableResult
    func with(_ configure: (Self) -> Void) -> Self {
        configure(self)
        return self
    }
}

extension NSObject: With {}
