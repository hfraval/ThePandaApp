import Foundation
import TPALogging

public final class AnalyticsService: AnalyticsServiceProtocol, @unchecked Sendable {
    private let logger: LoggerProtocol

    public init(logger: LoggerProtocol) {
        self.logger = logger
    }

    public func track(_ event: AnalyticsEvent) {
        var message = "📊 Analytics: \(event.name)"
        if !event.properties.isEmpty {
            let props = event.properties.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            message += " [\(props)]"
        }
        logger.info(message)
    }

    public func identify(userId: String, traits: [String: String]) {
        logger.info("📊 Analytics identify: userId=\(userId)")
    }

    public func reset() {
        logger.info("📊 Analytics reset")
    }
}
