import TPAFoundation

public enum AuthEvents {
    public struct SignedIn: Event, Equatable {
        public let user: User
        public init(user: User) { self.user = user }
    }

    public struct SignedOut: Event, Equatable {
        public init() {}
    }

    public struct Unauthorized: Event, Equatable {
        public init() {}
    }
}
