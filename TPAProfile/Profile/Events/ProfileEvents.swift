import TPAFoundation

public enum ProfileEvents {
    public struct Updated: Event, Equatable {
        public init() {}
    }

    public struct Viewed: Event, Equatable {
        public let userId: String
        public init(userId: String) { self.userId = userId }
    }
}
