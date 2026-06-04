# Project Review — ThePandaApp

> **Date:** 2026-06-02
> **Scope:** whole project — architecture, code quality, tests, gaps, risks.
> **Verdict:** the foundation is genuinely strong. This review focuses on what to improve next,
> ordered by impact. Items are tagged 🔴 high / 🟡 medium / 🟢 low / 💡 nice-to-have.
>
> **Update (2026-06-02): most items actioned.** Done: 🔴 Search error state (`SearchError` +
> `SearchEvents.Failed` + `.failed` view model + retry button); 🔴 session persistence
> (`SessionService` via `LocalStorageService`, restored on launch; `AuthService` marked MOCK);
> 🔴 concurrency (Auth/Session services + protocols now `@MainActor`, no `@unchecked Sendable`);
> 🟡 result-count header + category filter wired; 🟢 removed dead `locationField` &
> `BaseViewController`; added RequestProcessor + error-path tests. **Deferred:** infinite-scroll
> pagination (§3.1) — `limit`/`skip` plumbing exists, UI trigger not yet wired. Test count now 80+.

---

## 0. Test status (verified this session)

Fresh `xcodegen generate` + full run on iPhone 16 (iOS 18.6), all 3 brand schemes build:

| Bundle | Tests | Result |
|--------|------:|--------|
| ThePandaAppTests (App) | 9 | ✅ |
| TPAAuthTests | 13 | ✅ |
| TPADiscoveryTests | 2 | ✅ |
| TPAProfileTests | 10 | ✅ |
| TPASearchTests | 17 | ✅ |
| TPASettingsTests | 5 | ✅ |
| TPANetworkTests | 5 | ✅ |
| ScreenshotTests | 6 | ✅ |
| AppUITests | 7 | ✅ |
| **Total** | **74** | **`** TEST SUCCEEDED **`** |

Executed counts match source method counts in every bundle (no skipped/disabled tests).

---

## 1. What's strong (keep doing this)

- **Clean modular layering** (13 frameworks, ~5.1k LOC) with a real dependency graph and 3
  brand targets sharing one codebase via xcconfig. No layering violations found.
- **Disciplined unidirectional view architecture** — read-only providers, immutable `Equatable`
  view models, `Action → Service → Event → Provider` output loop, `callAsFunction` actions,
  analytics via `EventProcessor`. It's applied consistently across Auth/Discovery/Profile/Search/Settings.
- **DI everywhere behind protocols** → every layer is mockable; tests are fast and offline.
- **Network layer is well-factored** (Endpoint / RequestBuilder / processor chain / validator /
  decoder), async/await on `URLSession`, no third-party dependency, tested end-to-end via a
  `URLProtocolStub`.
- **No `TODO`/`FIXME`/`HACK` left in source**; force-unwraps are confined to safe spots
  (DI internals, static literal URL, `view!` after add). Good hygiene.

---

## 2. High-impact improvements 🔴

### 2.1 Services swallow errors → failures look like "empty results"
`DummyJSONSearchService.search` returns `[]` on **any** network/decoding failure, and the
provider maps an empty list to the `.empty` state. So a timeout / offline / 500 shows the user
"No results. Try different keywords or filters." — misleading, and there's no retry affordance.
- **Fix:** add a `.failed` (error) case to `SearchResultsViewModel` and a `SearchEvents.Failed`
  the service posts; render an error state with a Retry button. The `NetworkError` is already
  rich enough to message it. This is the one place the otherwise-clean event loop loses
  information.

### 2.2 No session/auth persistence
`AuthService`/`SessionService` keep the user only in memory; relaunching the app always returns
to signed-out. `LocalStorageService` exists but isn't used for the session.
- **Fix:** persist the signed-in `User` via `LocalStorageService` (and restore on launch in the
  composition root / `ProfileTabContentModelProvider`). Also `AuthService.login` accepts *any*
  non-empty credentials and mints a random `UUID` user — fine as a mock, but flag it as a known
  stub so it isn't mistaken for real auth.

### 2.3 `@unchecked Sendable` is used to silence concurrency, not to prove safety
Most services and mocks are `final class … @unchecked Sendable` with mutable state (e.g.
`AuthService.currentUser`, `SessionService.currentUser`, the mock counters). Under Swift 6
strict concurrency this compiles but the safety is asserted, not enforced — these are mutated
from `@MainActor` callers today but nothing guarantees it.
- **Fix:** make the stateful services `@MainActor` (they're UI-adjacent and already called from
  the main actor), or back their mutable state with a lock/actor. Reserve `@unchecked Sendable`
  for genuinely immutable types. This removes a latent data-race class as more async is added.

---

## 3. Medium-impact improvements 🟡

### 3.1 Pagination is modelled but not wired
`SearchQuery` has `limit`/`skip` and DummyJSON returns `total`, but the results list never loads
page 2 (no infinite scroll), and `total` is discarded. The `"search.results.count"` =
"%d results" string exists but is never shown.
- **Fix:** carry `total` into the results view model, show the count header, and trigger the next
  page from `scrollViewDidScroll` (or a prefetch data source) by re-running with `skip += limit`.

### 3.2 Category filter has no data source in the UI
The architecture supports `category` (server endpoint switch) and `DummyJSONEndpoint.categoryList()`
exists, but the filters screen never fetches/box-selects a category — only free text drives it.
- **Fix:** load the category list into the filters form (a picker), so the category filter is
  actually reachable from the UI. Right now 1 of the 7 filters is unreachable by a user.

### 3.3 `ServiceContainer` is a service-locator / global singleton
`ServiceContainer.shared` + `@Resolved` is pragmatic and tested, but it's global mutable state:
ordering bugs surface at runtime (`fatalError`/empty-container) rather than compile time, and the
two test-isolation hacks (`XCTestConfigurationFilePath` guard, per-test re-registration) exist
because of it.
- **Consider:** this is acceptable for the app's size; if it grows, move toward explicit
  init-injection at composition roots (the providers/actions already take init params, so the
  container is mostly a convenience). Not urgent — just know the trade-off.

### 3.4 Remote image loading is minimal
`UIImageView.setRemoteImage` is a global `NSCache` with no cancellation on cell reuse beyond a
token check, no disk cache, no down-sampling.
- **Fix (if image-heavy):** cancel the in-flight `Task` in `prepareForReuse`, add basic
  down-sampling for thumbnails. Fine as-is for a small list.

### 3.5 `Documentation/` is large and partly historical
Good docs (`ARCHITECTURE`, `API_SELECTION`, `NETWORK_INFRASTRUCTURE`) coexist with `DIAGRAMS.md`
and `APP_NAME_PROPOSALS.md`. Keep `ARCHITECTURE.md` as the single living source of truth and make
sure the others link to it rather than drift.

---

## 4. Low-impact / polish 🟢

- **`SearchBarView` still has a `locationField`** repurposed as "Category (optional)" but it's
  not wired to `SearchQuery.category` (search only uses the keywords field). Either wire it or
  remove it to avoid a dead control.
- **`BaseViewController` is unused** since the view refactor — remove it or adopt it as the base
  for screens that want the standard background.
- **`HTTPMethod` duplication risk** — fine now (single definition in Network), just keep it the
  one source.
- **`AnalyticsService` is a console-logging mock** — clearly marked; wire a real SDK behind the
  unchanged protocol when needed.
- **`ProfileLongMockViewController` (50 rows)** is a deliberate test affordance — make sure it's
  removed/replaced when real profile sections land (it's documented as temporary).
- **Brand `Brand.strings` tables are empty** — the per-brand override mechanism exists but is
  unused; confirm that's intended (all copy currently shared).

---

## 5. Testing gaps 💡

Coverage is good for providers/services/events. Worth adding:
- **Error-path tests** once §2.1 lands (service failure → error view model).
- **`RequestProcessor` unit tests** for `APIKeyProcessor`/`AuthTokenProcessor` (only
  `DefaultHeaders` is exercised indirectly).
- **A decoding test against a real captured DummyJSON fixture** (current decode tests use inline
  JSON; a saved fixture catches upstream shape drift).
- **Snapshot/screenshot diffing** — current screenshot tests *capture* attachments but don't
  *assert* against a baseline, so they can't catch visual regressions. Consider a reference-image
  comparison if visual stability matters.
- **Profile sticky-header behavior** is only structurally tested; a UI test that scrolls and
  asserts the header stays + the nav title appears would lock in the headline feature.

---

## 6. Suggested next-steps order

1. 🔴 Surface network errors in Search (§2.1) — best UX/robustness win, small change.
2. 🔴 Persist session (§2.2) — makes the app feel real across launches.
3. 🟡 Wire category + pagination + result count (§3.1, §3.2) — completes the Search feature.
4. 🔴 Tighten concurrency (`@MainActor` over `@unchecked Sendable`) (§2.3) — pay down before more async.
5. 🟢 Remove dead code (`locationField`, `BaseViewController`) and add the error-path tests (§5).

Nothing here is alarming — the architecture is sound and the test suite is green. These are the
moves that take it from "excellent scaffold" to "production-ready feature."
