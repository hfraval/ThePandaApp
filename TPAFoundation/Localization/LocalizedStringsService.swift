import Foundation

public final class LocalizedStringsService: LocalizedStringsServiceProtocol, @unchecked Sendable {

    private let bundle: Bundle
    private let tableNames: [String]

    private let animalName: String

    private let missingSentinel = "\u{0}__panda_localization_missing__"

    public init(bundle: Bundle = .main, tableNames: [String] = ["Brand", "Shared"]) {
        self.bundle = bundle
        self.tableNames = tableNames
        animalName = bundle.object(forInfoDictionaryKey: "BrandName") as? String
            ?? bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? "Panda"
    }

    public func localized(key: String, arguments args: [CVarArg]) -> String {
        let format = lookup(key: key)
        let branded = format.replacingOccurrences(of: "%ANIMAL%", with: animalName)
        guard !args.isEmpty else { return branded }
        return String(format: branded, locale: .current, arguments: args)
    }

    private func lookup(key: String) -> String {
        for table in tableNames {
            if let value = string(key: key, table: table) { return value }
        }
        return key
    }

    private func string(key: String, table: String) -> String? {
        let value = bundle.localizedString(forKey: key, value: missingSentinel, table: table)
        return value == missingSentinel ? nil : value
    }
}
