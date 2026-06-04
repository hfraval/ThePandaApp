import Foundation

@propertyWrapper
public struct Resolved<T> {
    private var service: T?

    public init() {}

    public var wrappedValue: T {
        mutating get {
            if service == nil {
                service = ServiceContainer.shared.resolve(T.self)
            }
            return service!
        }
        set { service = newValue }
    }
}
