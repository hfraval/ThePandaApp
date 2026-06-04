import Foundation

public struct Endpoint: Sendable {
    public var baseURL: URL
    public var path: String
    public var method: HTTPMethod
    public var query: [String: String]
    public var headers: [String: String]
    public var body: Data?
    public var acceptableStatusCodes: ClosedRange<Int>

    public init(
        baseURL: URL,
        path: String,
        method: HTTPMethod = .get,
        query: [String: String] = [:],
        headers: [String: String] = [:],
        body: Data? = nil,
        acceptableStatusCodes: ClosedRange<Int> = 200...299
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.query = query
        self.headers = headers
        self.body = body
        self.acceptableStatusCodes = acceptableStatusCodes
    }
}
