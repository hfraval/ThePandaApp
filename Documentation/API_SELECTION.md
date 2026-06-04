# API Selection & Specification

> **Audience:** the team + a future AI wiring real data into the Search/Discovery feature.
> **Goal:** pick a free mock-but-realistic API that returns **a list of items, each with an
> image, filterable by at least 5 different criteria**, and define the exact endpoints and
> response models we will decode.
> **Status:** ✅ **IMPLEMENTED (2026-06-02).** DummyJSON is wired live via
> `DummyJSONSearchService` (in `TPASearch`) over the `HTTPClient` in `TPANetwork`;
> `MockSearchService` remains behind `SearchServiceProtocol` for tests/offline (UI tests launch
> with `-uiTestMockSearch`). 7 filters implemented (text/category/sort server-side;
> price/rating/in-stock/brand client-side). Results render with thumbnails.
> **Date:** 2026-06-02

---

## 1. Requirements

1. Returns **a list** of something.
2. Each item has **an image**.
3. Supports **≥ 5 different filters** (so we can exercise the search/filter architecture).

(Nice-to-have, all satisfied by the winner: pagination + sorting, stable JSON, no auth/key.)

---

## 2. Candidate comparison

| API | List? | Image per item? | Native filters | Verdict |
|-----|-------|-----------------|----------------|---------|
| **DummyJSON** (`/products`) | ✅ `{ products: [...], total, skip, limit }` | ✅ `thumbnail` + `images[]` | search `q`, `category`, `sortBy`, `order`, `limit`/`skip`; rich item fields (price, rating, stock, brand, tags) for client-side filters | ✅ **Chosen** |
| JSONPlaceholder (`/posts`) | ✅ | ❌ posts have no image | field-equality + `_like` text | ❌ fails the image requirement |
| Open Library (`/search.json`) | ✅ `docs[]` | ✅ derive cover URL from `cover_i` | fielded query (title, author, subject, language, year) | ⚠️ strong on filters, but messy/sparse JSON and indirect image URLs |
| PokeAPI (`/pokemon`) | ✅ | ⚠️ only via a per-item detail fetch | ❌ list endpoint has no filtering | ❌ fails the ≥5-filters requirement |

**Decision: DummyJSON.** It is product/image-oriented (so the "list with an image" is
first-class), returns clean predictable JSON, needs no API key, and natively supports text
search + category + sort + pagination. The remaining filters we need are computed client-side
from fields the payload already returns (price, rating, stock, brand) — a realistic split that
also exercises our architecture's client-side filtering.

Base URL: `https://dummyjson.com`

---

## 3. Endpoints we will use

| Purpose | Request |
|---------|---------|
| List (paged) | `GET /products?limit={n}&skip={m}` |
| Text search | `GET /products/search?q={text}&limit={n}&skip={m}` |
| By category | `GET /products/category/{category}?limit={n}&skip={m}` |
| Category list (for the filter UI) | `GET /products/category-list` → `["beauty","fragrances",…]` |
| Sorted | append `&sortBy={field}&order={asc|desc}` (e.g. `sortBy=price&order=asc`) |

All list responses share the envelope `{ products, total, skip, limit }`.

> Note: DummyJSON applies `q`/`category`/`sortBy`/pagination **server-side**. Price range,
> minimum rating, in-stock, and brand are **not** server query params, so we apply them
> **client-side** to the returned page (documented in §5). This is intentional and typical.

---

## 4. The ≥5 filters

The Search feature's query expands from a single keyword into a filter set. Each filter maps to
either a server query parameter or a client-side predicate:

| # | Filter | Where applied | Maps to |
|---|--------|---------------|---------|
| 1 | **Search text** | server | `/products/search?q=` |
| 2 | **Category** | server | `/products/category/{category}` |
| 3 | **Sort by** (price / rating / title) | server | `&sortBy=&order=` |
| 4 | **Price range** (min…max) | client | filter `product.price` |
| 5 | **Minimum rating** | client | filter `product.rating >= x` |
| 6 | **In stock only** | client | filter `product.stock > 0` |
| 7 | **Brand** | client | filter `product.brand == x` |

(7 listed; ≥5 required.) Search text and Category are mutually exclusive at the endpoint level —
choose `/products/search` when text is present, else `/products/category/{c}` when a category is
chosen, else the plain `/products` list; then apply sort server-side and the client predicates.

---

## 5. Response & domain models (Swift)

### 5.1 Wire models — decode DummyJSON exactly

```swift
/// The list envelope returned by /products, /products/search, /products/category/{c}.
struct ProductListResponse: Decodable, Equatable {
    let products: [ProductDTO]
    let total: Int
    let skip: Int
    let limit: Int
}

/// One product as returned by DummyJSON. Only the fields we use are decoded; the rest are ignored.
struct ProductDTO: Decodable, Equatable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let rating: Double
    let stock: Int
    let brand: String?          // not present on every product
    let tags: [String]
    let thumbnail: String       // image URL
    let images: [String]
}
```

### 5.2 Domain model — what the UI renders

The existing `SearchResultItem` (in `TPASearch/Models/`) gains an image URL. Suggested
shape (rename the feature from "jobs" to "products", or keep generic):

```swift
public struct SearchResultItem: Equatable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String     // e.g. brand or category
    public let detail: String       // e.g. formatted price
    public let imageURL: URL?       // from ProductDTO.thumbnail
}
```

### 5.3 Filter model — what the query carries

Expand `SearchQuery` (currently `keywords` + `location`) into:

```swift
public struct SearchQuery: Equatable, Sendable {
    public enum SortField: String { case title, price, rating }
    public enum SortOrder: String { case asc, desc }

    public var text: String                 // filter 1  → q
    public var category: String?            // filter 2  → /category/{c}
    public var sortBy: SortField?           // filter 3  → sortBy
    public var order: SortOrder             // filter 3  → order
    public var priceRange: ClosedRange<Double>? // filter 4 (client)
    public var minimumRating: Double?       // filter 5 (client)
    public var inStockOnly: Bool            // filter 6 (client)
    public var brand: String?               // filter 7 (client)
    // pagination
    public var limit: Int
    public var skip: Int
}
```

### 5.4 Mapping (service responsibility)

```
SearchQuery
  → choose endpoint (search / category / list) + server params (q, category, sortBy, order, limit, skip)
  → GET → ProductListResponse
  → map ProductDTO → SearchResultItem (imageURL = URL(string: thumbnail),
                                       detail = price formatted, subtitle = brand ?? category)
  → apply client predicates (priceRange, minimumRating, inStockOnly, brand)
  → return [SearchResultItem]
```

This stays behind `SearchServiceProtocol` — `MockSearchService` returns canned data (used by UI
tests via `-uiTestMockSearch`), while `DummyJSONSearchService` performs the request via
`HTTPClientProtocol` (`TPANetwork`) and the mapping above. The unidirectional flow
(`RunSearchAction → SearchRunService → SearchEvents → SearchResultsContentModelProvider →
coordinated results container`) is independent of which service is registered; only the service
implementation swaps.

> Note: this document predates the implementation. The results screen was since built as a
> coordinated container (`CoordinatedStackContentViewController<SearchResultsContentModel>`) and
> `SearchEvents` gained a `Failed` case (error state with Retry). See `ARCHITECTURE.md`.

---

## 6. Sample requests (for reference)

```
GET https://dummyjson.com/products?limit=20&skip=0
GET https://dummyjson.com/products/search?q=phone&limit=20&skip=0&sortBy=price&order=asc
GET https://dummyjson.com/products/category/smartphones?limit=20&skip=0
GET https://dummyjson.com/products/category-list
```

Each product carries `thumbnail` (a usable image URL) and the fields needed for every filter in §4.

---

## 7. Suggested next steps (when moving off mocks)

1. Add the wire models (§5.1) to `TPASearch/Models/` (or a `…/Service/DTO/` subfolder).
2. Expand `SearchQuery` and `SearchResultItem` (§5.2–5.3); update `MockSearchService` to the
   richer shape so the UI keeps working.
3. Add `DummyJSONSearchService: SearchServiceProtocol` using `HTTPClientProtocol`; register it
   in `ServiceContainerRegistration` (swap `MockSearchService` → real, or keep mock behind a flag).
4. Build the filter UI as additional inputs feeding `SearchQuery` (the search bar already exists);
   each new control just sets a field on the query the action submits.
5. Tests: keep the mock-based unit tests; add decoding tests for `ProductListResponse` against a
   captured JSON fixture.
