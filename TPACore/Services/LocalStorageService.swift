import Foundation
import TPALogging

public final class LocalStorageService: LocalStorageServiceProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let logger: LoggerProtocol

    public init(defaults: UserDefaults = .standard, logger: LoggerProtocol) {
        self.defaults = defaults
        self.logger = logger
    }

    public func save<T: Codable>(_ value: T, forKey key: String) {
        do {
            let data = try encoder.encode(value)
            defaults.set(data, forKey: key)
        } catch {
            logger.error("LocalStorage save failed for key '\(key)': \(error)")
        }
    }

    public func load<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        do {
            return try decoder.decode(type, from: data)
        } catch {
            logger.error("LocalStorage load failed for key '\(key)': \(error)")
            return nil
        }
    }

    public func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
}
