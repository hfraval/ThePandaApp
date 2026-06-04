import Foundation

public struct LoginViewModel: Equatable, Sendable {
    let navigationTitle: String
    let title: String
    let subtitle: String
    let emailPlaceholder: String
    let passwordPlaceholder: String
    let loginButtonTitle: String
    let loadingMessage: String
    let isLoading: Bool
    let errorMessage: String?
}
