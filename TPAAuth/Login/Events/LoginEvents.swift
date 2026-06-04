import TPAFoundation

public enum LoginEvents {
    public struct Submitting: Event, Equatable {
        public init() {}
    }

    public struct Attempted: Event, Equatable {
        public let email: String
        public init(email: String) { self.email = email }
    }

    public struct Succeeded: Event, Equatable {
        public let userId: String
        public init(userId: String) { self.userId = userId }
    }

    public struct Failed: Event, Equatable {
        public let reason: String
        public init(reason: String) { self.reason = reason }
    }
}
