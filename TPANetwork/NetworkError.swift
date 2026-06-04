import Foundation

public enum NetworkError: Error, Sendable, Equatable {
    case invalidURL
    case noData
    case decodingFailed(String)
    case serverError(statusCode: Int, message: String?)
    case timeout
    case notConnected
    case cancelled
    case unknown
}
