import Foundation

@MainActor
public protocol SessionServiceProtocol: AnyObject, Sendable {
    var currentUser: User? { get }
    func setUser(_ user: User?)
    func clearSession()
}
