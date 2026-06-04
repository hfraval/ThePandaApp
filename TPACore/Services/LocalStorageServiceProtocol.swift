import Foundation

public protocol LocalStorageServiceProtocol: Sendable {
    func save<T: Codable>(_ value: T, forKey key: String)
    func load<T: Codable>(_ type: T.Type, forKey key: String) -> T?
    func remove(forKey key: String)
}
