# Network Service Infrastructure

> **Audience:** the team + a future AI building the real network layer in `TPANetwork`.
> **Goal:** define a clean, testable, async/await network infrastructure for classic REST APIs
> (our chosen backend is **DummyJSON**), informed by two reference
> projects. No GraphQL is needed now, but the design leaves room for it.
> **Status:** ✅ **IMPLEMENTED (2026-06-02).** `TPANetwork` now contains
> `Endpoint`, `RequestBuilder`, `RequestProcessor` (+ `DefaultHeaders`/`APIKey`/`AuthToken`),
> `HTTPClient`/`HTTPClientProtocol` (async, URLSession, no Alamofire), `ResponseDecoder`,
> `ResponseValidator`, extended `NetworkError`, `HTTPHeader`. Tested offline via `URLProtocolStub`
> (`TPANetworkTests`). The old `NetworkClient`/`NetworkRequest` stub was removed. GraphQL
> remains future work. The sections below describe the design as built.
> **Date:** 2026-06-02

---

## 1. What we learned from the two reference projects

### 1.1 WelcomingAssistant — clean classic-REST layering (our primary model)

Its `Network/` module separates concerns cleanly into single-responsibility pieces:

| Piece | Role |
|-------|------|
| `EndpointProtocol` (+ `Endpoint` enum) | Declares **where**: `scheme`, `host`, `path`, `httpMethod`, `headers`, `cachePolicy`; a default `url` is computed in a protocol extension. The concrete `Endpoint` is an **enum of cases** (one per API call) that switches host by build environment. |
| `URLRequestBuilder` (+ `JSONRequestBuilder`) | Turns an endpoint + an optional `Encodable` model into a `URLRequest`: GET/`ModelQueryable` → query items; POST/PUT/PATCH/DELETE → JSON body. |
| `Parser` (+ `JSONParser`) | Wraps `JSONDecoder.decode` behind a protocol (mockable, swappable). |
| `APIClient` | Performs the request, validates status code, maps non-2xx → error via pluggable hooks (`serverErrorInformationProcessor`, `httpErrorDescriptionProvider`, `httpResponseProcessor`), debug-logs. |
| `HttpError` | A `LocalizedError` value type keyed by status code, with named constants (`.unauthorized`, `.notFound`, …). |
| `HttpHeaderKeys` / `HttpHeaderValues` | Centralised header name/value constants. |
| `NetworkService` | The top-level facade the features call: `getModel(endpoint:parameterModel:) -> Model` (and a raw `getData`). It composes builder + client + parser. |

**Takeaways we adopt:** the Endpoint/Builder/Parser/Client/Error split; centralised header
constants; status-code → typed error mapping; a single `NetworkService` facade features depend
on. **What we drop:** RxSwift `Single` (we use async/await) and Alamofire (we use `URLSession`).

### 1.2 The reference app — async/await + request processors + GraphQL (selective borrowing)

The reference app is mostly GraphQL (Apollo) with a classic `SessionManager` for REST. The pieces worth
copying conceptually:

- **`requestDecodable<T>(_:) async throws -> T`** and `requestData(_:) async throws -> Data` —
  the modern async surface (it bridges Alamofire via `withUnsafeThrowingContinuation`; we get it
  for free from `URLSession`'s async API).
- **`RequestProcessor`** — `func process(_ request: URLRequest, requestFactory:) -> URLRequest`.
  A chain of small decorators that mutate the outgoing request: add auth header, add API key,
  add app-version header, add client-context header, etc. Each is one tiny testable unit.
- **`RequestFactory`** — a per-request descriptor (baseURL, path, method, parameters, which
  processors apply, whether to cache, etc.). This is the reference app's richer `Endpoint`.
- **`ResponseProcessor`** — a hook run on every response (e.g. read a refreshed token header).
- **GraphQL** lives in its own framework (a dedicated GraphQL module) behind a `GraphQLClient` facade with
  interceptors. **We do not need this yet** — but our facade boundary makes it addable later.

**Takeaways we adopt:** async/await surface; the **RequestProcessor decorator chain** for
cross-cutting request concerns (auth, api-key, default headers); a request-descriptor type.
**What we keep simple:** one processor list, no Alamofire, no GraphQL for v1.

---

## 2. Current state (`TPANetwork`) — the gap

```
NetworkClientProtocol.execute<T>(_ NetworkRequest) async -> Result<T, NetworkError>   // stub: always .failure(.unknown)
NetworkRequest { path, method, headers, body }
NetworkError { invalidURL, noData, decodingFailed, serverError, timeout, unknown }
HTTPMethod
```

It already has the right *shape* (async, `Result`, `Decodable` generic, a `NetworkError` enum)
and is DI-registered. It is just unimplemented and lacks: a base URL / endpoint concept, request
building (query items + JSON body), real `URLSession` execution + status mapping, request
decorators (headers/auth), and a feature-facing service facade. This doc fills those in **without
breaking the existing protocol** — features keep depending on a protocol; only the implementation
and a thin endpoint layer are added.

---

## 3. Target architecture

Layered, each piece single-responsibility and protocol-backed (so every layer is mockable).
All lives in `TPANetwork` (depends only on `Foundation` + `TPALogging`).

```
Feature (e.g. TPASearch)
        │  depends on a feature service protocol (SearchServiceProtocol)
        ▼
DummyJSONSearchService            ← feature-owned; maps domain ⇄ DTO, builds Endpoints
        │  calls
        ▼
HTTPClientProtocol                ← TPANetwork facade (async)
   .send<T: Decodable>(_ endpoint) async -> Result<T, NetworkError>
   .data(_ endpoint) async -> Result<Data, NetworkError>
        │  composes
        ├─ Endpoint                ← describes one call (baseURL, path, method, query, body, headers, processors)
        ├─ RequestBuilder          ← Endpoint (+ processors) → URLRequest
        ├─ [RequestProcessor]      ← decorate URLRequest (default headers, api-key, auth, user-agent)
        ├─ URLSession              ← performs the request (async)
        ├─ ResponseValidator       ← status code → success / NetworkError
        └─ ResponseDecoder         ← Data → T (JSONDecoder behind a protocol)
```

### 3.1 `Endpoint` — describe one call

```swift
public struct Endpoint: Sendable {
    public var baseURL: URL
    public var path: String
    public var method: HTTPMethod          // reuse existing HTTPMethod
    public var query: [String: String]     // → URLQueryItems (nil-safe, sorted for testability)
    public var headers: [String: String]   // per-call headers (merged over defaults)
    public var body: Data?                 // pre-encoded JSON for write methods
    public var acceptableStatusCodes: ClosedRange<Int>  // default 200...299

    public init(baseURL: URL, path: String, method: HTTPMethod = .get,
                query: [String: String] = [:], headers: [String: String] = [:],
                body: Data? = nil, acceptableStatusCodes: ClosedRange<Int> = 200...299)
}
```
Features build `Endpoint`s; a per-feature factory (or static helpers) keeps base URL + paths in
one place — the modern equivalent of WelcomingAssistant's `Endpoint` enum. Example:
```swift
enum DummyJSONEndpoint {
    static let base = URL(string: "https://dummyjson.com")!
    static func searchProducts(_ q: String, limit: Int, skip: Int, sortBy: String?, order: String) -> Endpoint {
        var query = ["q": q, "limit": "\(limit)", "skip": "\(skip)", "order": order]
        if let sortBy { query["sortBy"] = sortBy }
        return Endpoint(baseURL: base, path: "/products/search", method: .get, query: query)
    }
}
```

### 3.2 `RequestProcessor` — the decorator chain (from the reference app)

```swift
public protocol RequestProcessor: Sendable {
    func process(_ request: URLRequest) -> URLRequest
}
```
Composed in order by the client. v1 processors:
- `DefaultHeadersProcessor` — `Accept: application/json`, `Content-Type: application/json` (writes), `User-Agent`.
- `ApiKeyProcessor` — adds `X-Api-Key` when configured (no-op for DummyJSON; ready for real APIs).
- `AuthTokenProcessor` — adds `Authorization: Bearer <token>` from the session when signed in.
Each is one tiny unit, independently unit-tested. New cross-cutting concerns = a new processor,
not a change to the client.

### 3.3 `HTTPClientProtocol` — the async facade

```swift
public protocol HTTPClientProtocol: Sendable {
    func send<T: Decodable & Sendable>(_ endpoint: Endpoint) async -> Result<T, NetworkError>
    func data(_ endpoint: Endpoint) async -> Result<Data, NetworkError>
}

public final class HTTPClient: HTTPClientProtocol {
    // injected: URLSession, [RequestProcessor], ResponseDecoder, LoggerProtocol
    // 1. RequestBuilder builds URLRequest from Endpoint
    // 2. each RequestProcessor decorates it
    // 3. logger.debug(method + url)
    // 4. try await session.data(for: request)   (async URLSession — no Alamofire)
    // 5. ResponseValidator maps status code → .success / NetworkError.serverError(code)
    // 6. ResponseDecoder decodes T, or → .decodingFailed
    // 7. map thrown URLErrors → .timeout / .invalidURL / .unknown
}
```

> **Migration note on the existing `NetworkClientProtocol`:** keep it as a thin shim or fold it
> in. Cleanest path: rename/replace `NetworkClient` with `HTTPClient` conforming to a single
> protocol, and have it accept `Endpoint` instead of the bare `NetworkRequest`. `NetworkRequest`
> can be deleted once no caller uses it (only the stub does today). Update the DI registration.

### 3.4 `ResponseDecoder` & `ResponseValidator`

```swift
public protocol ResponseDecoder: Sendable { func decode<T: Decodable>(_ type: T.Type, from: Data) throws -> T }
public struct JSONResponseDecoder: ResponseDecoder { /* wraps a configured JSONDecoder */ }

enum ResponseValidator {
    static func validate(_ response: URLResponse, acceptable: ClosedRange<Int>) -> NetworkError?
}
```
(Parser behind a protocol = WelcomingAssistant's `Parser`; validator = its `APIClient` status
check.)

### 3.5 `NetworkError` (extend the existing enum)

Keep the current cases; make `serverError` carry an optional decoded server message so APIs that
return a JSON error body surface it (WelcomingAssistant's `serverErrorInformationProcessor`):
```swift
public enum NetworkError: Error, Sendable, Equatable {
    case invalidURL
    case noData
    case decodingFailed(String)            // String, not Error, so it stays Equatable for tests
    case serverError(statusCode: Int, message: String?)
    case timeout
    case notConnected
    case cancelled
    case unknown
}
```

### 3.6 Header constants

Add `HTTPHeader` namespacing (WelcomingAssistant's `HttpHeaderKeys`) so header names aren't
stringly-typed across processors:
```swift
public enum HTTPHeader {
    public static let accept = "Accept"
    public static let contentType = "Content-Type"
    public static let authorization = "Authorization"
    public static let apiKey = "X-Api-Key"
    public static let userAgent = "User-Agent"
}
```

---

## 4. How a feature uses it (Search, end-to-end)

This slots **under** the existing unidirectional view flow with zero UI/provider/action changes —
only the service implementation behind `SearchServiceProtocol` swaps from mock to real:

```
RunSearchAction(query:)  →  SearchRunService  →  await searchService.search(query)
                                                       │  (DummyJSONSearchService)
                                                       ├─ build Endpoint (DummyJSONEndpoint.searchProducts(…))
                                                       ├─ httpClient.send(endpoint) → Result<ProductListResponse, NetworkError>
                                                       ├─ map ProductDTO → SearchResultItem (imageURL from thumbnail)
                                                       └─ apply client-side filters (price/rating/stock/brand)
                                                  →  post(SearchEvents.Loaded(items:)) / .Failed
```
`SearchServiceProtocol` stays the seam: `MockSearchService` (canned) and `DummyJSONSearchService`
(real, depends on `HTTPClientProtocol`) are interchangeable via DI.

---

## 5. Dependency injection

Register in `App/Bootstrap/ServiceContainerRegistration.swift`:
```swift
container.registerSingleton(as: ResponseDecoder.self) { JSONResponseDecoder() }
container.registerSingleton(as: HTTPClientProtocol.self) {
    HTTPClient(
        session: .shared,
        processors: [DefaultHeadersProcessor(), ApiKeyProcessor(apiKey: nil), AuthTokenProcessor(session: container.resolve(SessionServiceProtocol.self))],
        decoder: container.resolve(ResponseDecoder.self),
        logger: container.resolve(LoggerProtocol.self)
    )
}
// Swap the mock for the real search service when ready:
container.registerSingleton(as: SearchServiceProtocol.self) {
    DummyJSONSearchService(httpClient: container.resolve(HTTPClientProtocol.self))
}
```
Keep `MockSearchService` registered behind a build flag / scheme so previews, tests, and offline
work stay fast and deterministic.

---

## 6. Testing strategy

- **`URLProtocol` stub** (`URLProtocolStub`) injected into a `URLSession` configuration → the
  `HTTPClient` is tested end-to-end against canned `(Data, HTTPURLResponse)` with **no real
  network** (this is exactly why WelcomingAssistant's `APIClient.init(configuration:)` exists).
  Put it in `TPAUnitTestFoundation`.
- **RequestProcessor unit tests** — each processor: given a `URLRequest`, assert the header it adds.
- **ResponseValidator tests** — 200/204 → nil; 401/404/500 → the right `NetworkError`.
- **Decoding tests** — decode `ProductListResponse` from a captured DummyJSON JSON fixture.
- **Feature service tests** — `DummyJSONSearchService` with a stubbed `HTTPClientProtocol`
  (return a fixed `ProductListResponse`) → assert domain mapping + client-side filters; the mock
  `HTTPClientProtocol` keeps these fast and offline.
- Existing event/provider tests are unaffected (the service seam is unchanged).

---

## 7. Build order (when implementing)

1. Extend `NetworkError`; add `HTTPHeader`; add `Endpoint` + `RequestBuilder`.
2. Add `RequestProcessor` + the 3 default processors.
3. Add `ResponseDecoder`/`ResponseValidator`; implement `HTTPClient` on `URLSession` async; add
   `HTTPClientProtocol`; register in DI; delete/retire the `NetworkRequest` stub.
4. Add `URLProtocolStub` to the test foundation; test the client + processors + validator.
5. In `TPASearch`: add `ProductListResponse`/`ProductDTO` DTOs, `DummyJSONEndpoint`,
   `DummyJSONSearchService`; wire DI; add decoding + mapping tests. UI/flow unchanged.
6. Later (only if needed): a `ThePandaAppGraphQL` framework behind its own client facade — the
   `HTTPClientProtocol` boundary means features won't care which transport a service uses.

---

## 8. Principles (carry-over from our architecture)

- **Every layer is a protocol** → mockable; features depend on protocols, never concrete clients.
- **async/await + `Result`** at the facade (matches the existing `NetworkClientProtocol` style).
- **Cross-cutting request concerns are processors**, not client edits.
- **No third-party networking dependency** — `URLSession` only (both references used Alamofire;
  modern URLSession async removes the need).
- **The network layer knows nothing about features**; features own their Endpoints, DTOs, and
  domain mapping, and expose a feature service protocol to the rest of the app.
- Keep mock services behind the same protocol so the app stays runnable/offline-testable.
