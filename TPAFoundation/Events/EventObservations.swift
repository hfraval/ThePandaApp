import Foundation

/// A bag of long-lived `Event` subscriptions that cancels them all when it is released.
///
/// Each `observe` consumes the typed `events(of:)` stream on its own `Task` and invokes the handler
/// per event, holding `target` **weakly** — so there is no retain cycle and the callback simply
/// stops once the target is gone. Hold one of these on the object doing the observing; when that
/// object deinits, this bag deinits with it and every subscription is torn down (its underlying
/// `NotificationCenter` observer removed). No manual `Task` storage or `deinit` cancellation needed
/// at the call site.
///
/// ```swift
/// private let observations = EventObservations()
/// init() {
///     observations.observe(LoginEvents.Failed.self, on: self) { provider, event in
///         provider.viewModel = .error(message: event.reason)
///     }
/// }
/// ```
@MainActor
public final class EventObservations {
    private var tasks: [Task<Void, Never>] = []

    public init() {}

    /// Observe every `E` event; `handler` runs on the main actor with the (still-alive) target.
    public func observe<Target: AnyObject, E: Event>(
        _ type: E.Type,
        on target: Target,
        perform handler: @escaping @MainActor (Target, E) -> Void
    ) {
        tasks.append(Task { [weak target] in
            for await event in events(of: type) {
                guard let target else { return }
                handler(target, event)
            }
        })
    }

    deinit {
        tasks.forEach { $0.cancel() }
    }
}
