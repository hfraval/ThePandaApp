import Foundation
import TPAFoundation
import TPACore
import TPADiscovery
import TPAAuth
import TPAProfile
import TPASettings

@MainActor
final class AppProcessors {
    private let discoveryTracking = DiscoveryViewedTrackingProcessor()
    private let loginTracking = LoginTrackingProcessor()
    private let profileTracking = ProfileTrackingProcessor()
    private let settingsTracking = SettingsPresentedTrackingProcessor()
    private let unauthorizedPolicy = UnauthorizedPolicyProcessor()

    init() {}
}
