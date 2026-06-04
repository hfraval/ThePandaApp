import TPAFoundation

public struct ProfileRegistrationCommand: ServiceContainerRegistrationCommand {
    public init() {}

    public func execute(for container: ServiceContainer) {
        container.registerSingleton(as: SuggestedLanguageNamesServiceProtocol.self) { SuggestedLanguageNamesService() }

        container.registerSingleton(as: LoadProfileActionProtocol.self) { LoadProfileAction() }
        container.registerSingleton(as: PresentEditPersonalDetailsActionProtocol.self) { PresentEditPersonalDetailsAction() }
        container.registerSingleton(as: SavePersonalDetailsActionProtocol.self) { SavePersonalDetailsAction() }
        container.registerSingleton(as: SaveProfileLanguageActionProtocol.self) { SaveProfileLanguageAction() }
        container.registerSingleton(as: DeleteProfileLanguageActionProtocol.self) { DeleteProfileLanguageAction() }
        container.registerSingleton(as: SaveNextRoleActionProtocol.self) { SaveNextRoleAction() }
    }
}
