# Testing

How the project tests, modelled on the reference app's test infrastructure. We follow the
**testing pyramid**: a wide base of fast unit tests, a middle band of snapshot tests, and a thin
top of end-to-end UI tests.

```
        ╱╲        UI tests (XCUITest)   — few, slow, full user journeys (AppUITests)
       ╱──╲
      ╱────╲      Snapshot tests        — render each screen → compare to a committed image
     ╱──────╲                              (ScreenshotTests)
    ╱────────╲    Unit tests            — many, fast, per-framework logic (…Tests targets)
   ╱──────────╲
```

- **Unit tests** — one bundle per framework; cover providers, services, commands, endpoints,
  processors, validation, DI, etc.
- **Snapshot tests** — see [Snapshot testing](#snapshot-testing).
- **UI tests** — see [UI testing](#ui-testing).
- **Shared support** — `TPAUnitTestFoundation` holds base test cases (`TestCase`/`AppTestCase`),
  mocks, a `URLProtocol` stub, and the snapshot engine.

---

## Snapshot testing

### How the reference app does it

The reference app uses **Point-Free's SnapshotTesting**, wrapped in an `assertAppearance` helper:

- A test calls `assertAppearance { makeViewController() }`.
- The helper renders the screen for each entry in a **config dictionary** (light, dark, iPad,
  locales…), each config defining device size, `userInterfaceStyle`, language and content-size.
- Each render is compared against a **committed reference PNG** in `__Snapshots__/<TestFile>/`
  next to the test (named `<test>.<config>.png`).
- A global `isRecording` (set in a `TestSetup` principal class) regenerates references; missing
  references are recorded and the test fails as a reminder.

So the "images" are real PNGs **committed to the repo** — the test fails if a screen's appearance
drifts from its reference.

### How we do it

Same author-facing shape, but **dependency-free** (the project ships no third-party deps): a small
engine in `TPAUnitTestFoundation/Snapshot/SnapshotTesting.swift`.

```swift
@MainActor
final class ProfileScreenshotTests: ScreenshotTestCase {
    @MockResolved<ProfileServiceProtocol, MockProfileService> var _profile
    @MockResolved<SessionServiceProtocol, MockSessionService> var _session

    override func setUp() async throws {
        try await super.setUp()
        _session.currentUser = .mock
    }

    func test_profileScreen_withData() {
        _profile.getProfileResult = .success(
            UserProfile(userId: "1", firstName: "Panda", lastName: "Bear", email: "panda@example.com")
        )
        assertAppearance { ProfileViewController() }
    }
}
```

- **`assertAppearance(configs:record:afterLayout:_:)`** renders the view controller for each
  `SnapshotConfig` (default = `light` + `dark`), then records or compares.
- **References** live in `ScreenshotTests/**/__Snapshots__/<TestFile>/<test>.<config>.png` and are
  **committed**. View any of them to see the rendered screen.
- **`afterLayout`** runs after layout, before capture — used e.g. to scroll the Profile so its
  section tab bar docks before capturing (`test_profileScreen_tabBarDocked`).
- **Async, mock-backed content** (Action → Service → Event → provider) is allowed to settle via a
  short run-loop spin before capture, so screens that load on appear render fully.
- Rendering uses `window.layer.render(in:)` (reliable for an off-screen window) at `@2x`.
- Comparison is tolerant (small per-channel + overall-ratio allowance) to avoid anti-aliasing
  flakiness while still catching real changes.

**Recording / updating references:** set `isRecordingSnapshots = true` in `SnapshotTesting.swift`,
run the `ScreenshotTests` (they write PNGs and fail as a reminder), set it back to `false`, and run
again to verify. Review the regenerated PNGs in the diff before committing.

`ScreenshotTestCase` is the base (registers app mocks via `AppTestCase`, disables animations).

---

## UI testing

### How the reference app does it

The reference app's UI tests are built from **distinct layers** (in a `UITestFoundation` framework):

1. **Elements** (page objects) — one per screen (`SignInOrRegisterForm`, `SearchForm`,
   `NavigationBar`…) wrapping that screen's `XCUIElement` queries, exposed via an
   **`XCTestCase+Elements`** factory.
2. **Steps** — BDD sentence methods grouped into per-feature protocols (`NavigationSteps`,
   `SearchSteps`, `JobDetailSteps`…), each `where Self: XCTestCase`, driving the Elements. A base
   **`Steps`** protocol adds `Given` / `When` / `Then` / `And` (no-op passthroughs returning
   `self`) purely for readability.
3. **Launch scenarios** — `launch(.mockEverything, .loggedOut, …)` configures app state per test,
   including `.resetAppState` for isolation; a stub server makes network deterministic.
4. **Tests** adopt the step protocols they need and read as `Given.…() When.…() Then.…()`.

### How we do it

The same layering, in `AppUITests/`:

```
AppUITests/
├── Foundation/
│   ├── AppUITestCase.swift          ← base: adopts Steps; launch(_ scenarios:) (+ always -uiTestReset)
│   ├── XCTestCase+Elements.swift    ← page-object factory (tabBar, loginScreen, …)
│   └── XCUIElement+Helpers.swift    ← waitToExist / tapWhenReady / type
├── Elements/                         ← LAYER 1: page objects
│   ├── AppTabBarElement.swift · LoginScreenElement.swift · DiscoveryScreenElement.swift
│   └── SearchResultsScreenElement.swift · ProfileScreenElement.swift
├── Steps/                            ← LAYER 2: BDD steps
│   ├── Steps.swift                   ← Given / When / Then / And
│   ├── NavigationSteps.swift · LoginSteps.swift · SearchSteps.swift
├── LoginUITests.swift                ← LAYER 3: journeys
└── SearchUITests.swift
```

```swift
final class SearchUITests: AppUITestCase, NavigationSteps, SearchSteps {
    func test_search_pushesResults() {
        launch(.mockSearch)                 // deterministic offline backend
        Given.Open_The_Discovery_Tab()
        And.The_Search_Bar_Is_Shown()
        When.I_Search_For("iOS")
        Then.The_Search_Results_Are_Shown()
    }
}
```

- **Layer 1 — Elements** key off the same accessibility identifiers the screens set.
- **Layer 2 — Steps** are sentence methods (`Open_The_Discovery_Tab`, `The_Search_Results_Are_Shown`)
  in per-feature protocols; `Given`/`When`/`Then`/`And` are grammar sugar.
- **Layer 3 — Tests** adopt the step protocols and read as user journeys.
- **Launch scenarios:** `launch(_ scenarios: Scenario...)` always passes `-uiTestReset` (the app
  clears any persisted session at startup, so a test that signs in doesn't leak into the next),
  plus opt-ins like `.mockSearch`.
- **To add a screen:** add an `…Element` (+ register it in `XCTestCase+Elements`), add a
  `…Steps` protocol of sentences, then write the journey adopting that protocol.

---

## Running

```bash
xcodebuild test -project ThePandaApp.xcodeproj -scheme ThePandaApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Or `⌘U` in Xcode. All test bundles run from the `ThePandaApp` scheme.
