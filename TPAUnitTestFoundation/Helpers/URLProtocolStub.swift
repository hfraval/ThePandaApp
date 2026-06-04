import Foundation

public final class URLProtocolStub: URLProtocol {
    public struct Stub {
        public let data: Data?
        public let statusCode: Int
        public let error: Error?
    }

    nonisolated(unsafe) private static var stub: Stub?
    nonisolated(unsafe) public private(set) static var lastRequest: URLRequest?

    public static func stub(data: Data?, statusCode: Int = 200, error: Error? = nil) {
        stub = Stub(data: data, statusCode: statusCode, error: error)
    }

    public static func reset() {
        stub = nil
        lastRequest = nil
    }

    public override class func canInit(with request: URLRequest) -> Bool { true }
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    public override func startLoading() {
        Self.lastRequest = request

        if let error = Self.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        let statusCode = Self.stub?.statusCode ?? 200
        if let url = request.url,
           let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil) {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let data = Self.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    public override func stopLoading() {}
}
