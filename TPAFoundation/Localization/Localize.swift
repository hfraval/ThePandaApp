import Foundation

public func localize(_ key: String, _ args: CVarArg...) -> String {
    localize(key, arguments: args)
}

public func localize(_ key: String, arguments args: [CVarArg]) -> String {
    localizationService.localized(key: key, arguments: args)
}

private var localizationService: LocalizedStringsServiceProtocol {
    ServiceContainer.shared.resolveOptional(LocalizedStringsServiceProtocol.self)
        ?? LocalizationFallback.service
}

private enum LocalizationFallback {
    static let service: LocalizedStringsServiceProtocol = LocalizedStringsService()
}
