import Foundation
import TPACore

public final class MockLocalStorageService: LocalStorageServiceProtocol, @unchecked Sendable {
    private var store: [String: Data] = [:]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init() {}

    public func save<T: Codable>(_ value: T, forKey key: String) {
        store[key] = try? encoder.encode(value)
    }

    public func load<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = store[key] else { return nil }
        return try? decoder.decode(type, from: data)
    }

    public func remove(forKey key: String) {
        store.removeValue(forKey: key)
    }
}
