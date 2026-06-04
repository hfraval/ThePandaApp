import Foundation
import TPACore
import TPAFoundation
import TPAUIKit

@MainActor
final class ProfileTabContentModelProvider {
    @Resolved private var sessionService: SessionServiceProtocol

    private var contentModel: ProfileTabContentModel {
        didSet { updateDelegate() }
    }

    weak var delegate: AnyContentModelProviderDelegate<ProfileTabContentModel>? {
        didSet { updateDelegate() }
    }

    init() {
        if let user = ServiceContainer.shared.resolve(SessionServiceProtocol.self).currentUser {
            contentModel = .signedIn(user)
        } else {
            contentModel = .signedOut
        }
        observe(self, event: AuthEvents.SignedIn.self, selector: #selector(handleSignedIn(_:)))
        observe(self, event: AuthEvents.SignedOut.self, selector: #selector(handleSignedOut))
    }

    @objc private func handleSignedIn(_ note: Notification) {
        guard let event: AuthEvents.SignedIn = note.eventPayload() else { return }
        contentModel = .signedIn(event.user)
    }

    @objc private func handleSignedOut() {
        contentModel = .signedOut
    }

    private func updateDelegate() {
        delegate?.contentModelUpdated(contentModel)
    }
}
