import Foundation

@MainActor
public protocol ServiceContainerRegistrationCommand {
    func execute(for container: ServiceContainer)
}
