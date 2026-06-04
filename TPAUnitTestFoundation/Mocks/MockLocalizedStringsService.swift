import Foundation
import TPAFoundation

public final class MockLocalizedStringsService: LocalizedStringsServiceProtocol, @unchecked Sendable {
    public var localizedReturnValue: String?
    public private(set) var localizedCallCount = 0
    public private(set) var lastKey: String?
    public private(set) var lastArguments: [CVarArg] = []

    public init() {}

    public func localized(key: String, arguments args: [CVarArg]) -> String {
        localizedCallCount += 1
        lastKey = key
        lastArguments = args
        return localizedReturnValue ?? key
    }
}
