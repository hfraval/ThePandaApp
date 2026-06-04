import Foundation

public final class Logger: LoggerProtocol, @unchecked Sendable {
    private let minimumLevel: LogLevel
    private let dateFormatter: DateFormatter

    public init(minimumLevel: LogLevel = .debug) {
        self.minimumLevel = minimumLevel
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
    }

    public func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        guard level >= minimumLevel else { return }
        let filename = URL(fileURLWithPath: file).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        print("[\(timestamp)] \(level.prefix) [\(filename):\(line)] \(message)")
    }
}
