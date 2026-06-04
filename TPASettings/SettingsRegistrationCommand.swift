import TPAFoundation

public struct SettingsRegistrationCommand: ServiceContainerRegistrationCommand {
    public init() {}

    public func execute(for container: ServiceContainer) {
        container.registerSingleton(as: SettingsLogoutActionProtocol.self) { SettingsLogoutAction() }
    }
}
