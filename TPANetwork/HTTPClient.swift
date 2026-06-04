import Foundation
import TPALogging

public protocol HTTPSession: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPSession {}

public protocol HTTPClientProtocol: Sendable {
    func send<T: Decodable & Sendable>(_ endpoint: Endpoint) async -> Result<T, NetworkError>
    func data(_ endpoint: Endpoint) async -> Result<Data, NetworkError>
}

public final class HTTPClient: HTTPClientProtocol {
    private let session: HTTPSession
    private let processors: [RequestProcessor]
    private let responseProcessors: [ResponseProcessor]
    private let decoder: ResponseDecoder
    private let logger: LoggerProtocol

    public init(
        session: HTTPSession,
        processors: [RequestProcessor],
        responseProcessors: [ResponseProcessor] = [],
        decoder: ResponseDecoder,
        logger: LoggerProtocol
    ) {
        self.session = session
        self.processors = processors
        self.responseProcessors = responseProcessors
        self.decoder = decoder
        self.logger = logger
    }

    public func send<T: Decodable & Sendable>(_ endpoint: Endpoint) async -> Result<T, NetworkError> {
        let result = await data(endpoint)
        switch result {
        case .success(let data):
            do {
                return .success(try decoder.decode(T.self, from: data))
            } catch {
                logger.error("Decoding \(T.self) failed: \(error)")
                return .failure(.decodingFailed(String(describing: error)))
            }
        case .failure(let error):
            return .failure(error)
        }
    }

    public func data(_ endpoint: Endpoint) async -> Result<Data, NetworkError> {
        guard var request = RequestBuilder.makeRequest(from: endpoint) else {
            return .failure(.invalidURL)
        }
        for processor in processors {
            request = processor.process(request)
        }

        logger.debug("Network: \(endpoint.method.rawValue) \(request.url?.absoluteString ?? endpoint.path)")

        do {
            let (data, response) = try await session.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            if let error = ResponseValidator.validate(response, acceptable: endpoint.acceptableStatusCodes) {
                logger.error("Network: \(endpoint.path) → \(error)")
                await runResponseProcessors(request: request, statusCode: statusCode, data: data, error: error)
                return .failure(error)
            }
            await runResponseProcessors(request: request, statusCode: statusCode, data: data, error: nil)
            return .success(data)
        } catch {
            let networkError = Self.map(error)
            await runResponseProcessors(request: request, statusCode: nil, data: nil, error: networkError)
            return .failure(networkError)
        }
    }

    private func runResponseProcessors(
        request: URLRequest,
        statusCode: Int?,
        data: Data?,
        error: NetworkError?
    ) async {
        guard !responseProcessors.isEmpty else { return }
        let context = NetworkResponseContext(request: request, statusCode: statusCode, data: data, error: error)
        for processor in responseProcessors {
            await processor.process(context)
        }
    }

    private static func map(_ error: Error) -> NetworkError {
        guard let urlError = error as? URLError else { return .unknown }
        switch urlError.code {
        case .timedOut: return .timeout
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed: return .notConnected
        case .cancelled: return .cancelled
        case .badURL, .unsupportedURL: return .invalidURL
        default: return .unknown
        }
    }
}
