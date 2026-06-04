/// The login screen's dynamic state — the only thing that changes while the screen is shown.
/// Static copy (titles, placeholders, button text) is a View concern and lives in `LoginScreen`.
public enum LoginViewModel: Equatable, Sendable {
    /// Default state: the form is ready for input.
    case idle
    /// A login attempt is in flight.
    case loading
    /// The last attempt failed; carries the already-localized message to show.
    case error(message: String)
}
