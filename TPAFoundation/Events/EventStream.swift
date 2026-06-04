import Foundation

/// Structured-concurrency bridge over the `Event` notification bus.
///
/// Returns an `AsyncStream` that yields every posted `Event` of type `E`. Because `Event: Sendable`,
/// only the typed payload — never a non-`Sendable` `Notification` — crosses into the consuming
/// (often actor-isolated) context, so it is clean under strict concurrency.
///
/// The underlying `NotificationCenter` observer is removed automatically when the stream terminates
/// (consumer task cancelled or the loop ends), so callers only need to hold/cancel the consuming
/// `Task`:
///
/// ```swift
/// let task = Task { [weak self] in
///     for await _ in events(of: LoginEvents.Submitting.self) { self?.handleSubmitting() }
/// }
/// // later: task.cancel()
/// ```
public func events<E: Event>(of type: E.Type) -> AsyncStream<E> {
    let center = eventNotificationCenter()
    return AsyncStream { continuation in
        // The opaque observer token is only ever touched on the notification queue and in
        // `onTermination`; it is safe to carry across the stream's isolation boundary.
        nonisolated(unsafe) let observer = center.addObserver(
            forName: E.notificationName,
            object: nil,
            queue: nil
        ) { notification in
            guard let payload: E = notification.eventPayload() else { return }
            continuation.yield(payload)
        }

        continuation.onTermination = { _ in
            center.removeObserver(observer)
        }
    }
}
