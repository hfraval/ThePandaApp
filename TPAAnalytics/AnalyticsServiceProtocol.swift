import Foundation

public protocol AnalyticsServiceProtocol: Sendable {
    func track(_ event: AnalyticsEvent)
    func identify(userId: String, traits: [String: String])
    func reset()
}
