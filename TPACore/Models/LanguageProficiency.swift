import Foundation

public enum LanguageLevel: String, Codable, Equatable, Sendable, CaseIterable {
    case basic
    case conversational
    case fluent
    case native

    public var displayName: String {
        switch self {
        case .basic: return "Basic"
        case .conversational: return "Conversational"
        case .fluent: return "Fluent"
        case .native: return "Native"
        }
    }
}

public struct LanguageProficiency: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public var name: String
    public var level: LanguageLevel

    public init(id: String = UUID().uuidString, name: String, level: LanguageLevel) {
        self.id = id
        self.name = name
        self.level = level
    }
}
