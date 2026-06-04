import TPAFoundation

public struct AuthRegistrationCommand: ServiceContainerRegistrationCommand {
    public init() {}

    public func execute(for container: ServiceContainer) {
        container.registerSingleton(as: LoginServiceProtocol.self) { LoginService() }
        container.registerSingleton(as: LoginActionProtocol.self) { LoginAction() }
        container.registerSingleton(as: LoginViewModelProviderProtocol.self) { LoginViewModelProvider() }
    }
}
