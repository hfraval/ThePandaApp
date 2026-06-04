import Foundation
import TPANetwork

public final class MockHTTPClient: HTTPClientProtocol, @unchecked Sendable {
    public var dataResult: Result<Data, NetworkError> = .failure(.unknown)
    public private(set) var sentEndpoints: [Endpoint] = []

    private let decoder = JSONResponseDecoder()

    public init() {}

    public func send<T: Decodable & Sendable>(_ endpoint: Endpoint) async -> Result<T, NetworkError> {
        sentEndpoints.append(endpoint)
        switch dataResult {
        case .success(let data):
            do { return .success(try decoder.decode(T.self, from: data)) }
            catch { return .failure(.decodingFailed(String(describing: error))) }
        case .failure(let error):
            return .failure(error)
        }
    }

    public func data(_ endpoint: Endpoint) async -> Result<Data, NetworkError> {
        sentEndpoints.append(endpoint)
        return dataResult
    }

    public func stub<T: Encodable>(_ model: T) {
        dataResult = (try? JSONEncoder().encode(model)).map(Result.success) ?? .failure(.unknown)
    }
}
