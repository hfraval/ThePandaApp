import Foundation
import TPACore
import TPAFoundation

@MainActor
protocol LoadProfileActionProtocol {
    func callAsFunction()
}

@MainActor
final class LoadProfileAction: LoadProfileActionProtocol {
    @Resolved private var profileService: ProfileServiceProtocol
    @Resolved private var sessionService: SessionServiceProtocol

    func callAsFunction() {
        if let userId = sessionService.currentUser?.id {
            post(ProfileEvents.Viewed(userId: userId))
        }
        Task { await profileService.refresh() }
    }
}
