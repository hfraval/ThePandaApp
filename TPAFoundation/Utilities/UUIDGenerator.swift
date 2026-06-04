import Foundation

public protocol UUIDGeneratorProtocol: Sendable {
    func generate() -> String
}

public struct UUIDGenerator: UUIDGeneratorProtocol {
    public init() {}

    public func generate() -> String {
        UUID().uuidString
    }
}
