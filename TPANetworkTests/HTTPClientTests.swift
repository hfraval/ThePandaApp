import XCTest
import TPAUnitTestFoundation
@testable import TPANetwork

@MainActor
final class HTTPClientTests: AppTestCase {
    private struct Sample: Decodable, Equatable { let id: Int; let name: String }

    private var client: HTTPClient!

    override func setUp() async throws {
        try await super.setUp()
        URLProtocolStub.reset()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        client = HTTPClient(
            session: URLSession(configuration: config),
            processors: [DefaultHeadersProcessor()],
            decoder: JSONResponseDecoder(),
            logger: MockLogger()
        )
    }

    override func tearDown() async throws {
        URLProtocolStub.reset()
        client = nil
        try await super.tearDown()
    }

    private func endpoint() -> Endpoint {
        Endpoint(baseURL: URL(string: "https://example.com")!, path: "/thing")
    }

    func test_send_success_decodes() async {
        URLProtocolStub.stub(data: Data(#"{"id":1,"name":"Panda"}"#.utf8), statusCode: 200)
        let result: Result<Sample, NetworkError> = await client.send(endpoint())
        XCTAssertEqual(try? result.get(), Sample(id: 1, name: "Panda"))
    }

    func test_send_serverError_mapsStatusCode() async {
        URLProtocolStub.stub(data: Data(), statusCode: 404)
        let result: Result<Sample, NetworkError> = await client.send(endpoint())
        XCTAssertEqual(result.failureError, .serverError(statusCode: 404, message: nil))
    }

    func test_send_badJSON_mapsDecodingFailed() async {
        URLProtocolStub.stub(data: Data("not json".utf8), statusCode: 200)
        let result: Result<Sample, NetworkError> = await client.send(endpoint())
        if case .failure(.decodingFailed) = result { } else { XCTFail("expected decodingFailed, got \(result)") }
    }

    func test_data_buildsURLWithSortedQuery() async {
        URLProtocolStub.stub(data: Data("{}".utf8), statusCode: 200)
        let ep = Endpoint(baseURL: URL(string: "https://example.com")!, path: "/search",
                          query: ["q": "ios", "limit": "10"])
        _ = await client.data(ep)
        let url = URLProtocolStub.lastRequest?.url?.absoluteString
        XCTAssertEqual(url, "https://example.com/search?limit=10&q=ios")
    }

    func test_defaultHeadersProcessor_addsAccept() async {
        URLProtocolStub.stub(data: Data("{}".utf8), statusCode: 200)
        _ = await client.data(endpoint())
        XCTAssertEqual(URLProtocolStub.lastRequest?.value(forHTTPHeaderField: "Accept"), "application/json")
    }
}

@MainActor
final class RequestProcessorTests: AppTestCase {
    private func request() -> URLRequest {
        URLRequest(url: URL(string: "https://example.com")!)
    }

    func test_apiKeyProcessor_addsHeaderWhenKeyPresent() {
        let out = APIKeyProcessor(apiKey: "secret").process(request())
        XCTAssertEqual(out.value(forHTTPHeaderField: "X-Api-Key"), "secret")
    }

    func test_apiKeyProcessor_noHeaderWhenKeyNil() {
        let out = APIKeyProcessor(apiKey: nil).process(request())
        XCTAssertNil(out.value(forHTTPHeaderField: "X-Api-Key"))
    }

    func test_authTokenProcessor_addsBearerWhenSignedIn() {
        let out = AuthTokenProcessor(tokenProvider: { "abc123" }).process(request())
        XCTAssertEqual(out.value(forHTTPHeaderField: "Authorization"), "Bearer abc123")
    }

    func test_authTokenProcessor_noHeaderWhenSignedOut() {
        let out = AuthTokenProcessor(tokenProvider: { nil }).process(request())
        XCTAssertNil(out.value(forHTTPHeaderField: "Authorization"))
    }

    func test_defaultHeadersProcessor_setsContentTypeOnlyWithBody() {
        var withBody = request(); withBody.httpBody = Data("{}".utf8)
        XCTAssertEqual(DefaultHeadersProcessor().process(withBody).value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNil(DefaultHeadersProcessor().process(request()).value(forHTTPHeaderField: "Content-Type"))
    }
}

private final class RecordingResponseProcessor: ResponseProcessor, @unchecked Sendable {
    private(set) var contexts: [NetworkResponseContext] = []
    func process(_ context: NetworkResponseContext) async { contexts.append(context) }
}

@MainActor
final class ResponseProcessorTests: AppTestCase {
    private struct Sample: Decodable { let id: Int }

    private func makeClient(
        response: [ResponseProcessor],
        request: [RequestProcessor] = []
    ) -> HTTPClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        return HTTPClient(
            session: URLSession(configuration: config),
            processors: request,
            responseProcessors: response,
            decoder: JSONResponseDecoder(),
            logger: MockLogger()
        )
    }

    private func authenticatingProcessors() -> [RequestProcessor] {
        [AuthTokenProcessor(tokenProvider: { "test-token" })]
    }

    private func endpoint() -> Endpoint {
        Endpoint(baseURL: URL(string: "https://example.com")!, path: "/thing")
    }

    override func setUp() async throws {
        try await super.setUp()
        URLProtocolStub.reset()
    }

    override func tearDown() async throws {
        URLProtocolStub.reset()
        try await super.tearDown()
    }

    func test_responseProcessor_runsOnSuccess_withStatusCode() async {
        URLProtocolStub.stub(data: Data("{}".utf8), statusCode: 200)
        let recorder = RecordingResponseProcessor()
        _ = await makeClient(response: [recorder]).data(endpoint())
        XCTAssertEqual(recorder.contexts.count, 1)
        XCTAssertEqual(recorder.contexts.first?.statusCode, 200)
        XCTAssertNil(recorder.contexts.first?.error)
    }

    func test_responseProcessor_runsOnFailure_withError() async {
        URLProtocolStub.stub(data: Data(), statusCode: 500)
        let recorder = RecordingResponseProcessor()
        _ = await makeClient(response: [recorder]).data(endpoint())
        XCTAssertEqual(recorder.contexts.first?.statusCode, 500)
        XCTAssertNotNil(recorder.contexts.first?.error)
    }

    func test_unauthorizedProcessor_firesOn401_forAuthenticatedRequest() async {
        URLProtocolStub.stub(data: Data(), statusCode: 401)
        let fired = Fired()
        let processor = UnauthorizedResponseProcessor { await fired.set() }
        _ = await makeClient(response: [processor], request: authenticatingProcessors()).data(endpoint())
        let didFire = await fired.value
        XCTAssertTrue(didFire)
    }

    func test_unauthorizedProcessor_doesNotFireOn401_forUnauthenticatedRequest() async {
        URLProtocolStub.stub(data: Data(), statusCode: 401)
        let fired = Fired()
        let processor = UnauthorizedResponseProcessor { await fired.set() }
        _ = await makeClient(response: [processor]).data(endpoint())
        let didFire = await fired.value
        XCTAssertFalse(didFire)
    }

    func test_unauthorizedProcessor_doesNotFireOn200() async {
        URLProtocolStub.stub(data: Data("{}".utf8), statusCode: 200)
        let fired = Fired()
        let processor = UnauthorizedResponseProcessor { await fired.set() }
        _ = await makeClient(response: [processor], request: authenticatingProcessors()).data(endpoint())
        let didFire = await fired.value
        XCTAssertFalse(didFire)
    }

    private actor Fired {
        private(set) var value = false
        func set() { value = true }
    }
}

private extension Result where Failure == NetworkError {
    var failureError: NetworkError? {
        if case .failure(let e) = self { return e }
        return nil
    }
}
