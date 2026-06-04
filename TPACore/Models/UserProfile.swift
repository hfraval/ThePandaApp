import Foundation

public struct UserProfile: Codable, Equatable, Sendable {
    public let userId: String
    public var firstName: String
    public var lastName: String
    public var email: String
    public var languages: [LanguageProficiency]
    public var nextRole: NextRolePreferences

    public init(
        userId: String,
        firstName: String,
        lastName: String,
        email: String,
        languages: [LanguageProficiency] = [],
        nextRole: NextRolePreferences = .empty
    ) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.languages = languages
        self.nextRole = nextRole
    }

    public var fullName: String {
        [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
    }
}

public extension UserProfile {
    static var mock: UserProfile {
        UserProfile(
            userId: "mock-user-001",
            firstName: "Panda",
            lastName: "Bear",
            email: "panda@example.com",
            languages: [
                LanguageProficiency(id: "lang-english", name: "English", level: .native),
                LanguageProficiency(id: "lang-mandarin", name: "Mandarin", level: .conversational)
            ],
            nextRole: NextRolePreferences(
                availability: .withinOneMonth,
                salary: "$120,000",
                approachability: .openToOpportunities
            )
        )
    }
}
