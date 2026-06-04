import Foundation
import TPALogging

public final class MockLogger: LoggerProtocol, @unchecked Sendable {
    public private(set) var messages: [(String, LogLevel)] = []

    public init() {}

    public func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        messages.append((message, level))
    }
}
