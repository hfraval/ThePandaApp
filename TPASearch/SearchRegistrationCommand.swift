import TPAFoundation

public struct SearchRegistrationCommand: ServiceContainerRegistrationCommand {
    public init() {}

    public func execute(for container: ServiceContainer) {
        container.registerSingleton(as: SearchRunServiceProtocol.self) { SearchRunService() }
        container.registerSingleton(as: RunSearchActionProtocol.self) { RunSearchAction() }
        container.registerSingleton(as: PresentSearchResultsActionProtocol.self) { PresentSearchResultsAction() }
        container.registerSingleton(as: PresentFiltersActionProtocol.self) { PresentFiltersAction() }
    }
}
