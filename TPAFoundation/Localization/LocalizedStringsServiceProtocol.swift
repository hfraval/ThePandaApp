import Foundation

public protocol LocalizedStringsServiceProtocol: Sendable {
    func localized(key: String, arguments args: [CVarArg]) -> String
}

public extension LocalizedStringsServiceProtocol {
    func localized(key: String, _ args: CVarArg...) -> String {
        localized(key: key, arguments: args)
    }
}
