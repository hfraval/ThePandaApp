import Foundation

public final class ServiceContainer: @unchecked Sendable {
    public static let shared = ServiceContainer()

    private var services: [String: Any] = [:]
    private var factories: [String: () -> Any] = [:]
    private let lock = NSLock()

    private init() {}

    public func registerInstance<T>(_ instance: T, as type: T.Type) {
        let key = String(describing: type)
        lock.lock()
        defer { lock.unlock() }
        services[key] = instance
    }

    public func registerSingleton<T>(as type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        lock.lock()
        defer { lock.unlock() }
        factories[key] = factory
    }

    public func resolve<T>(_ type: T.Type) -> T {
        guard let instance = resolveOptional(type) else {
            fatalError("[ServiceContainer] No registration found for type: \(type)")
        }
        return instance
    }

    public func resolveOptional<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)

        lock.lock()
        if let service = services[key] as? T {
            lock.unlock()
            return service
        }
        let factory = factories[key]
        lock.unlock()

        guard let factory else {
            return nil
        }

        let instance = factory() as! T

        lock.lock()
        defer { lock.unlock() }
        if let existing = services[key] as? T {
            return existing
        }
        services[key] = instance
        factories.removeValue(forKey: key)
        return instance
    }

    public func reset() {
        lock.lock()
        defer { lock.unlock() }
        services.removeAll()
        factories.removeAll()
    }
}
