import Foundation
import TPAFoundation

@propertyWrapper
public struct MockResolved<Protocol, Mock: AnyObject> {
    private var mock: Mock?

    public init() {}

    public var wrappedValue: Mock {
        mutating get {
            if mock == nil {
                mock = ServiceContainer.shared.resolve(Protocol.self) as? Mock
                assert(mock != nil, "[MockResolved] Could not cast resolved \(Protocol.self) to \(Mock.self). Did you register it in AppTestCase?")
            }
            return mock!
        }
    }
}
