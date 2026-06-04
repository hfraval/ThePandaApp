import Foundation

public enum Availability: String, Codable, Equatable, Sendable, CaseIterable {
    case immediately
    case withinOneMonth
    case withinThreeMonths

    public var displayName: String {
        switch self {
        case .immediately: return "Available immediately"
        case .withinOneMonth: return "Within 1 month"
        case .withinThreeMonths: return "Within 3 months"
        }
    }
}

public enum Approachability: String, Codable, Equatable, Sendable, CaseIterable {
    case openToOpportunities
    case openToOffers
    case notLooking

    public var displayName: String {
        switch self {
        case .openToOpportunities: return "Open to opportunities"
        case .openToOffers: return "Open to offers only"
        case .notLooking: return "Not looking"
        }
    }
}

public struct NextRolePreferences: Codable, Equatable, Sendable {
    public var availability: Availability?
    public var salary: String?
    public var approachability: Approachability?

    public init(availability: Availability? = nil, salary: String? = nil, approachability: Approachability? = nil) {
        self.availability = availability
        self.salary = salary
        self.approachability = approachability
    }

    public static var empty: NextRolePreferences { NextRolePreferences() }
}
