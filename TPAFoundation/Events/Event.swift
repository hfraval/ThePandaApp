import Foundation

public protocol Event: Sendable {}

public extension Event {
    static var notificationName: Notification.Name {
        Notification.Name(String(reflecting: self))
    }
}

func eventNotificationCenter() -> NotificationCenter {
    ServiceContainer.shared.resolveOptional(NotificationCenter.self) ?? .default
}

private let eventPayloadKey = "payload"

public func post(_ event: Event) {
    eventNotificationCenter().post(
        name: type(of: event).notificationName,
        object: nil,
        userInfo: [eventPayloadKey: event]
    )
}

public extension Event {
    func post() {
        TPAFoundation.post(self)
    }
}

public func observe(
    _ observer: Any,
    event: Event.Type,
    selector: Selector
) {
    eventNotificationCenter().addObserver(
        observer,
        selector: selector,
        name: event.notificationName,
        object: nil
    )
}

public extension Notification {
    func eventPayload<T: Event>() -> T? {
        userInfo?[eventPayloadKey] as? T
    }
}
