import Foundation
import TPAAnalytics

public final class MockAnalyticsService: AnalyticsServiceProtocol, @unchecked Sendable {
    public private(set) var trackedEvents: [AnalyticsEvent] = []
    public private(set) var identifiedUserIds: [String] = []
    public private(set) var resetCallCount = 0

    public init() {}

    public func track(_ event: AnalyticsEvent) {
        trackedEvents.append(event)
    }

    public func identify(userId: String, traits: [String: String]) {
        identifiedUserIds.append(userId)
    }

    public func reset() {
        resetCallCount += 1
    }

    public func hasTracked(_ eventName: String) -> Bool {
        trackedEvents.contains { $0.name == eventName }
    }
}
