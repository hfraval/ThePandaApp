import Foundation

public protocol RequestProcessor: Sendable {
    func process(_ request: URLRequest) -> URLRequest
}

public struct DefaultHeadersProcessor: RequestProcessor {
    private let userAgent: String

    public init(userAgent: String = "ThePandaApp/1.0") {
        self.userAgent = userAgent
    }

    public func process(_ request: URLRequest) -> URLRequest {
        var request = request
        request.setValueIfAbsent(HTTPHeaderValue.applicationJSON, forHeader: HTTPHeader.accept)
        request.setValueIfAbsent(userAgent, forHeader: HTTPHeader.userAgent)
        if request.httpBody != nil {
            request.setValueIfAbsent(HTTPHeaderValue.applicationJSON, forHeader: HTTPHeader.contentType)
        }
        return request
    }
}

public struct APIKeyProcessor: RequestProcessor {
    private let apiKey: String?

    public init(apiKey: String?) {
        self.apiKey = apiKey
    }

    public func process(_ request: URLRequest) -> URLRequest {
        guard let apiKey else { return request }
        var request = request
        request.setValue(apiKey, forHTTPHeaderField: HTTPHeader.apiKey)
        return request
    }
}

public struct AuthTokenProcessor: RequestProcessor {
    private let tokenProvider: @Sendable () -> String?

    public init(tokenProvider: @escaping @Sendable () -> String?) {
        self.tokenProvider = tokenProvider
    }

    public func process(_ request: URLRequest) -> URLRequest {
        guard let token = tokenProvider() else { return request }
        var request = request
        request.setValue(HTTPHeaderValue.bearerPrefix + token, forHTTPHeaderField: HTTPHeader.authorization)
        return request
    }
}

private extension URLRequest {
    mutating func setValueIfAbsent(_ value: String, forHeader header: String) {
        guard self.value(forHTTPHeaderField: header) == nil else { return }
        setValue(value, forHTTPHeaderField: header)
    }
}
