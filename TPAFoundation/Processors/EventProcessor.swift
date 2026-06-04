import Foundation

open class EventProcessor<TEvent: Event>: Processor, @unchecked Sendable {
    private let center: NotificationCenter
    private var observer: NSObjectProtocol?

    public init() {
        let center = eventNotificationCenter()
        self.center = center
        observer = center.addObserver(
            forName: TEvent.notificationName,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            guard let payload: TEvent = notification.eventPayload() else { return }
            self?.handle(payload)
        }
    }

    deinit {
        if let observer {
            center.removeObserver(observer)
        }
    }

    open func handle(_ event: TEvent) {
        fatalError("EventProcessor subclasses must override handle(_:)")
    }
}
