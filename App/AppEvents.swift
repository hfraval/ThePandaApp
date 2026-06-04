import Foundation

enum AppEvents {
    struct ColdStart: Sendable {
        init() {}
    }
    struct WarmStart: Sendable {}
    struct DidBecomeActive: Sendable {}
    struct WillResignActive: Sendable {}
    struct DidEnterBackground: Sendable {}
}
