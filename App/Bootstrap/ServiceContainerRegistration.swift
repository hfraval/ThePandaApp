import Foundation
import TPAFoundation
import TPALogging
import TPACore
import TPANetwork
import TPAAnalytics
import TPAAuth
import TPAProfile
import TPADiscovery
import TPASearch
import TPASettings

enum ServiceContainerRegistration {
    @MainActor
    static func register() {
        let container = ServiceContainer.shared

        container.registerInstance(NotificationCenter.default, as: NotificationCenter.self)
        container.registerSingleton(as: DateFactoryProtocol.self) { DateFactory() }
        container.registerSingleton(as: UUIDGeneratorProtocol.self) { UUIDGenerator() }

        container.registerSingleton(as: LoggerProtocol.self) {
            Logger(minimumLevel: .debug)
        }

        container.registerSingleton(as: LocalizedStringsServiceProtocol.self) {
            LocalizedStringsService()
        }

        container.registerSingleton(as: LocalStorageServiceProtocol.self) {
            LocalStorageService(logger: container.resolve(LoggerProtocol.self))
        }
        container.registerSingleton(as: AuthServiceProtocol.self) {
            AuthService(logger: container.resolve(LoggerProtocol.self))
        }
        container.registerSingleton(as: SessionServiceProtocol.self) {
            SessionService(
                storage: container.resolve(LocalStorageServiceProtocol.self),
                logger: container.resolve(LoggerProtocol.self)
            )
        }
        container.registerSingleton(as: AppLifecycleServiceProtocol.self) {
            AppLifecycleService(logger: container.resolve(LoggerProtocol.self))
        }

        container.registerSingleton(as: ResponseDecoder.self) { JSONResponseDecoder() }
        container.registerSingleton(as: HTTPClientProtocol.self) {
            HTTPClient(
                session: URLSession.shared,
                processors: [
                    DefaultHeadersProcessor(),
                    APIKeyProcessor(apiKey: nil),
                    AuthTokenProcessor(tokenProvider: { nil })
                ],
                responseProcessors: [
                    UnauthorizedResponseProcessor {
                        post(AuthEvents.Unauthorized())
                    }
                ],
                decoder: container.resolve(ResponseDecoder.self),
                logger: container.resolve(LoggerProtocol.self)
            )
        }

        container.registerSingleton(as: AnalyticsServiceProtocol.self) {
            AnalyticsService(logger: container.resolve(LoggerProtocol.self))
        }

        container.registerSingleton(as: ProfileServiceProtocol.self) { ProfileService() }

        let useMockSearch = ProcessInfo.processInfo.arguments.contains("-uiTestMockSearch")
        container.registerSingleton(as: SearchServiceProtocol.self) { () -> SearchServiceProtocol in
            if useMockSearch {
                return MockSearchService()
            }
            return DummyJSONSearchService(httpClient: container.resolve(HTTPClientProtocol.self))
        }

        registerFeatures(in: container)

        container.registerSingleton(as: PresentSettingsActionProtocol.self) { PresentSettingsAction() }
        container.registerSingleton(as: SearchBarFactory.self) { AppSearchBarFactory() }

        if ProcessInfo.processInfo.arguments.contains("-uiTestReset") {
            container.resolve(SessionServiceProtocol.self).clearSession()
        }
    }

    @MainActor
    static func registerFeatures(in container: ServiceContainer) {
        let commands: [ServiceContainerRegistrationCommand] = [
            AuthRegistrationCommand(),
            SearchRegistrationCommand(),
            ProfileRegistrationCommand(),
            SettingsRegistrationCommand()
        ]
        commands.forEach { $0.execute(for: container) }
    }
}
