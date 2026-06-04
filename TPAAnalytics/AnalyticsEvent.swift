import Foundation

public struct AnalyticsEvent: Sendable {
    public let name: String
    public let properties: [String: String]

    public init(name: String, properties: [String: String] = [:]) {
        self.name = name
        self.properties = properties
    }
}

public extension AnalyticsEvent {
    static func appColdStart() -> AnalyticsEvent {
        AnalyticsEvent(name: "app_cold_start")
    }

    static func appWarmStart() -> AnalyticsEvent {
        AnalyticsEvent(name: "app_warm_start")
    }

    static func loginAttempt(email: String) -> AnalyticsEvent {
        AnalyticsEvent(name: "login_attempt", properties: ["email": email])
    }

    static func loginSuccess(userId: String) -> AnalyticsEvent {
        AnalyticsEvent(name: "login_success", properties: ["user_id": userId])
    }

    static func loginFailure(reason: String) -> AnalyticsEvent {
        AnalyticsEvent(name: "login_failure", properties: ["reason": reason])
    }

    static func logoutSuccess() -> AnalyticsEvent {
        AnalyticsEvent(name: "logout_success")
    }

    static func profileViewed(userId: String) -> AnalyticsEvent {
        AnalyticsEvent(name: "profile_viewed", properties: ["user_id": userId])
    }

    static func discoveryViewed() -> AnalyticsEvent {
        AnalyticsEvent(name: "discovery_viewed")
    }
}
