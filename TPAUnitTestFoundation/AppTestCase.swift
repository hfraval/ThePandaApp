import XCTest
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

open class AppTestCase: TestCase {
    open override func setUp() async throws {
        try await super.setUp()
        registerMocks()
    }

    private func registerMocks() {
        let container = ServiceContainer.shared
        container.registerInstance(NotificationCenter(),           as: NotificationCenter.self)
        container.registerInstance(MockLogger(),                   as: LoggerProtocol.self)
        container.registerInstance(MockLocalizedStringsService(),  as: LocalizedStringsServiceProtocol.self)
        container.registerInstance(MockAuthService(),              as: AuthServiceProtocol.self)
        container.registerInstance(MockSessionService(),           as: SessionServiceProtocol.self)
        container.registerInstance(MockAnalyticsService(),         as: AnalyticsServiceProtocol.self)
        container.registerInstance(MockHTTPClient(),               as: HTTPClientProtocol.self)
        container.registerInstance(MockProfileService(),           as: ProfileServiceProtocol.self)
        container.registerInstance(MockLocalStorageService(),      as: LocalStorageServiceProtocol.self)
        container.registerInstance(MockAppLifecycleService(),      as: AppLifecycleServiceProtocol.self)

        AuthRegistrationCommand().execute(for: container)
        SearchRegistrationCommand().execute(for: container)
        ProfileRegistrationCommand().execute(for: container)
        SettingsRegistrationCommand().execute(for: container)

        container.registerInstance(TestSearchBarFactory() as SearchBarFactory, as: SearchBarFactory.self)
        container.registerInstance(TestPresentSettingsAction() as PresentSettingsActionProtocol, as: PresentSettingsActionProtocol.self)
    }
}
