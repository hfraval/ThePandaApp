import XCTest
import TPAUnitTestFoundation
@testable import TPAFoundation

private final class Thing { let id = UUID() }
private protocol Greeter { var name: String { get } }
private final class RealGreeter: Greeter { let name = "real" }

private final class Dependent {
    let greeter: Greeter
    init(greeter: Greeter) { self.greeter = greeter }
}

private final class Holder {
    @Resolved var greeter: Greeter
}

private final class IdentitySet: @unchecked Sendable {
    private let lock = NSLock()
    private(set) var ids = Set<ObjectIdentifier>()
    func add(_ id: ObjectIdentifier) { lock.lock(); ids.insert(id); lock.unlock() }
}

@MainActor
final class ServiceContainerTests: TestCase {

    func test_registerInstance_resolves() {
        let thing = Thing()
        ServiceContainer.shared.registerInstance(thing, as: Thing.self)
        XCTAssertTrue(ServiceContainer.shared.resolve(Thing.self) === thing)
    }

    func test_resolveOptional_returnsNilWhenUnregistered() {
        XCTAssertNil(ServiceContainer.shared.resolveOptional(Thing.self))
    }

    func test_registerSingleton_isLazyAndCachesSameInstance() {
        var factoryCalls = 0
        ServiceContainer.shared.registerSingleton(as: Thing.self) {
            factoryCalls += 1
            return Thing()
        }
        XCTAssertEqual(factoryCalls, 0)

        let first = ServiceContainer.shared.resolve(Thing.self)
        let second = ServiceContainer.shared.resolve(Thing.self)

        XCTAssertEqual(factoryCalls, 1, "singleton factory must run only once")
        XCTAssertTrue(first === second, "subsequent resolves must return the cached instance")
    }

    func test_factoryResolvingDependency_doesNotDeadlock() {
        ServiceContainer.shared.registerSingleton(as: Greeter.self) { RealGreeter() }
        ServiceContainer.shared.registerSingleton(as: Dependent.self) {
            Dependent(greeter: ServiceContainer.shared.resolve(Greeter.self))
        }

        let dependent = ServiceContainer.shared.resolve(Dependent.self)

        XCTAssertEqual(dependent.greeter.name, "real")
    }

    func test_reset_clearsRegistrations() {
        ServiceContainer.shared.registerInstance(Thing(), as: Thing.self)
        ServiceContainer.shared.reset()
        XCTAssertNil(ServiceContainer.shared.resolveOptional(Thing.self))
    }

    func test_resolved_propertyWrapper_resolvesLazily() {
        ServiceContainer.shared.registerSingleton(as: Greeter.self) { RealGreeter() }
        let holder = Holder()
        XCTAssertEqual(holder.greeter.name, "real")
    }

    func test_concurrentResolve_returnsSameSingletonInstance() {
        ServiceContainer.shared.registerSingleton(as: Thing.self) { Thing() }
        let collected = IdentitySet()

        DispatchQueue.concurrentPerform(iterations: 64) { _ in
            collected.add(ObjectIdentifier(ServiceContainer.shared.resolve(Thing.self)))
        }

        XCTAssertEqual(collected.ids.count, 1, "all concurrent resolves must return one canonical instance")
    }
}
