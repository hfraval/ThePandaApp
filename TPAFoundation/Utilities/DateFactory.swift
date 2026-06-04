import Foundation

public protocol DateFactoryProtocol: Sendable {
    func now() -> Date
}

public struct DateFactory: DateFactoryProtocol {
    public init() {}

    public func now() -> Date {
        Date()
    }
}
