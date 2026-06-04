import Foundation

public enum LogLevel: Int, Sendable, Comparable {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var prefix: String {
        switch self {
        case .verbose: return "🔍 VERBOSE"
        case .debug:   return "🐛 DEBUG"
        case .info:    return "ℹ️ INFO"
        case .warning: return "⚠️ WARNING"
        case .error:   return "❌ ERROR"
        }
    }
}
