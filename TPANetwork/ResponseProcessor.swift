import Foundation

public struct NetworkResponseContext: Sendable {
    public let request: URLRequest
    public let statusCode: Int?
    public let data: Data?
    public let error: NetworkError?

    public init(request: URLRequest, statusCode: Int?, data: Data?, error: NetworkError?) {
        self.request = request
        self.statusCode = statusCode
        self.data = data
        self.error = error
    }
}

public protocol ResponseProcessor: Sendable {
    func process(_ context: NetworkResponseContext) async
}

public struct UnauthorizedResponseProcessor: ResponseProcessor {
    private let onUnauthorized: @Sendable () async -> Void

    public init(onUnauthorized: @escaping @Sendable () async -> Void) {
        self.onUnauthorized = onUnauthorized
    }

    public func process(_ context: NetworkResponseContext) async {
        guard context.statusCode == 401,
              context.request.value(forHTTPHeaderField: HTTPHeader.authorization) != nil
        else { return }
        await onUnauthorized()
    }
}
