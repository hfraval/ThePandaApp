import Foundation
import TPAFoundation

public protocol SuggestedLanguageNamesServiceProtocol: Sendable {
    func suggestions(for text: String) async -> [LanguageNameSuggestion]
}

public final class SuggestedLanguageNamesService: SuggestedLanguageNamesServiceProtocol, @unchecked Sendable {
    private static let allLanguages = [
        "Arabic", "Bengali", "Cantonese", "Dutch", "English", "French", "German", "Greek",
        "Hindi", "Indonesian", "Italian", "Japanese", "Korean", "Mandarin", "Polish",
        "Portuguese", "Russian", "Spanish", "Thai", "Turkish", "Vietnamese"
    ]

    public init() {}

    public func suggestions(for text: String) async -> [LanguageNameSuggestion] {
        try? await Task.sleep(nanoseconds: 120_000_000)
        let needle = text.trimmed.lowercased()
        guard !needle.isEmpty else { return [] }
        return Self.allLanguages
            .filter { $0.lowercased().hasPrefix(needle) }
            .map { LanguageNameSuggestion(id: $0.lowercased(), text: $0) }
    }
}
