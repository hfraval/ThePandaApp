import TPAFoundation

public enum SearchEvents {
    public struct Submitting: Event, Equatable {
        public init() {}
    }

    public struct Loaded: Event, Equatable {
        public let items: [SearchResultItem]
        public init(items: [SearchResultItem]) { self.items = items }
    }

    public struct Failed: Event, Equatable {
        public init() {}
    }

    public struct Searched: Event, Equatable {
        public let keywords: String
        public init(keywords: String) { self.keywords = keywords }
    }
}
