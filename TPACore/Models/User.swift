import Foundation

public struct User: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let email: String

    public init(id: String, email: String) {
        self.id = id
        self.email = email
    }
}

public extension User {
    static var mock: User {
        User(id: "mock-user-001", email: "panda@example.com")
    }
}
