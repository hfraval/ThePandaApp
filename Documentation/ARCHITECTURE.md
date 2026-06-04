# ThePandaApp — Architecture Reference

> The architecture reference for the project — the long-form rationale behind how the code is
> organised, including a C4 view, the framework layering, and the unidirectional view layer.

## Origin

A 4-layer modular framework architecture: a foundation layer, infrastructure frameworks, feature frameworks, and thin per-brand app targets that share one codebase.

---

## Framework Layer Hierarchy

```
┌──────────────────────────────────────────────────────────┐
│                   App Targets (Layer 3)                  │
│   ThePandaApp  ·  TheRoosterApp  ·  TheKoalaApp         │
│   (3 targets share App/ sources, differ only via xcconfig) │
├──────────────────────────────────────────────────────────┤
│               Feature Frameworks (Layer 2)               │
│  TPAAuth  ·  TPADiscovery  ·  TPASearch │
│  TPAProfile  ·  TPASettings              │
├──────────────────────────────────────────────────────────┤
│            Infrastructure Frameworks (Layer 1)           │
│  TPACore  ·  TPANetwork                  │
│  TPAAnalytics (MOCKED — no external SDK)         │
├──────────────────────────────────────────────────────────┤
│              Foundation Frameworks (Layer 0)             │
│  TPAFoundation  ·  TPALogging            │
│  TPAUIKit                                        │
├──────────────────────────────────────────────────────────┤
│                     iOS SDK                              │
│              UIKit  ·  Foundation  ·  XCTest             │
└──────────────────────────────────────────────────────────┘
```

**Rule:** Dependencies only flow downward. Feature frameworks must not import each other.

---

## Framework Dependency Matrix

| Framework | Depends On |
|-----------|-----------|
| TPAFoundation | (none) |
| TPALogging | Foundation |
| TPAUIKit | Foundation |
| TPACore | Foundation, Logging |
| TPANetwork | Foundation, Logging |
| TPAAnalytics | Foundation, Logging |
| **TPAAuth** | Foundation, Logging, UIKit, Core, Analytics |
| **TPADiscovery** | Foundation, Logging, UIKit, Analytics, Search |
| **TPASearch** | Foundation, Logging, UIKit, Analytics |
| TPAProfile | Foundation, Logging, UIKit, Core, Network, Analytics, Settings |
| **TPASettings** | Foundation, Logging, UIKit, Core, Analytics |
| ThePandaApp / TheRoosterApp / TheKoalaApp | All of the above |
| TPAUnitTestFoundation | Foundation, Logging, Core, Network, Analytics, Auth, Discovery, Profile, Search, Settings |

---

## C4 model (context → components)

A [C4](https://c4model.com) view of the app at three zoom levels. *Level 2 (containers)* is the
Framework Layer Hierarchy + Dependency Matrix above.

### Level 1 — System context

```
   ┌──────────┐   browse / search products,    ┌─────────────────────────────┐
   │   User   │ ──────  edit own profile  ────▶ │  ThePandaApp (iOS system)   │ ───▶ DummyJSON
   └──────────┘                                 │  Panda · Rooster · Koala    │      product REST API
                                                └─────────────────────────────┘ ····▶ analytics / crash
                                                                                       SDKs (mocked)
```

- **Person** — the user browsing/searching products and editing their own profile.
- **System** — the iOS app: one codebase shipped as three brands (Panda / Rooster / Koala).
- **External systems** — the **DummyJSON** product REST API (the only live backend); analytics,
  crash reporting and remote config are **mocked / absent** for now (`TPAAnalytics` is the seam,
  ready for a real SDK).

### Level 2 — Containers

The runnable/linkable units are the three **app targets** and the **modular frameworks** they
compose, plus the external API — see *Framework Layer Hierarchy* and *Framework Dependency Matrix*
above. Dependencies flow strictly downward; features never import each other (they talk via `Event`s).

### Level 3 — Components (the Search feature)

Zooming into one feature framework, `TPASearch`:

```
TPASearch
├── Models     SearchQuery · SearchResultItem · ProductDTO · ProductListResponse
├── Service     SearchServiceProtocol → { DummyJSONSearchService | MockSearchService } ·
│               SearchRunService (posts Events) · ApplyClientFiltersCommand (sub-pattern)
├── Events      SearchEvents { Submitting · Loaded · Failed · Searched }
├── SearchBar   View · ViewController · ViewModel(+Provider) · PresentSearchResultsAction
├── Results     CoordinatedStackContentViewController<SearchResultsContentModel>
│               ├── SearchResultsContentModel (enum) + …Provider (read-only)
│               ├── children:  Count · List · Empty · Loading · Error  (each CoordinatedContent)
│               └── RunSearchAction · SearchResultCell
├── Filters     CoordinatedStackContentViewController<SearchFiltersContentModel>
│               ├── SearchFiltersContentModelProvider + one Processor per filter
│               └── children:  Category · SortBy · Price · Rating · InStock · Brand
│                   (each posts a SearchFilterEvents.…DidUpdate; the provider folds it into the draft)
└── Tracking    SearchEvents.Searched (observed by a processor, wired at app level)
```

Every feature decomposes the same way: domain **Models**, feature **Service(s)** that post
**Events**, and per-screen `ViewController` / `View` / `ViewModel` / `…Provider` / `Action`(s), with
**Commands** / **Processors** added where useful.

### Architectural roles vs. sub-patterns

`ViewModelProvider`, `Action`, and `Event` are the **architectural roles** — together they define
the shape of every screen (data **down** via a pushed view model; intent **out** via an Action;
results **back** as an Event the provider observes). `Command` and `Processor` are **sub-patterns**,
not layers: code-splitting devices used *inside* providers / actions / services (a pure logic unit;
a long-lived Event observer). You can build the entire loop without ever naming a `Command` — which
is why they sit one level down (see *File Type Roles*).

---

## App Targets: 3 Animals, 1 Codebase

All three targets compile identical `App/` sources. They differ only via xcconfig:

| Setting | ThePandaApp | TheRoosterApp | TheKoalaApp |
|---------|-------------|---------------|-------------|
| Bundle ID (Debug) | com.thepandaapp.panda.debug | com.thepandaapp.rooster.debug | com.thepandaapp.koala.debug |
| Bundle ID (Release) | com.thepandaapp.panda | com.thepandaapp.rooster | com.thepandaapp.koala |
| Display Name | Panda | Rooster | Koala |
| AppIcon | Configuration/ThePandaApp/app/Resources/Assets.xcassets | TheRoosterApp/… | TheKoalaApp/… |
| Brand Color | Forest green | Crimson | Slate blue |

---

## Configuration Folder Structure

```
Configuration/
├── project/
│   ├── project-Shared.xcconfig     ← Swift version, deployment target, test flags
│   ├── project-Debug.xcconfig      ← DEBUG compile flag
│   └── project-Release.xcconfig    ← Optimisation flags
│
├── Shared/
│   └── app/Resources/en.lproj/Shared.strings   ← all shared localized copy (main bundle)
│
├── ThePandaApp/
│   ├── app/
│   │   ├── ThePandaApp-app-Shared.xcconfig   ← PRODUCT_NAME, INFOPLIST_FILE
│   │   ├── ThePandaApp-app-Debug.xcconfig    ← Bundle ID (.debug), display name
│   │   ├── ThePandaApp-app-Release.xcconfig  ← Bundle ID, display name
│   │   └── Resources/
│   │       └── Assets.xcassets/
│   │           └── AppIcon.appiconset/       ← Replace AppIcon-1024.png with final art
│   └── shared/resources/
│       └── Colors.xcassets/
│           └── BrandPrimary.colorset/        ← Brand accent colour
│
├── TheRoosterApp/  (same structure)
└── TheKoalaApp/    (same structure)
```

xcconfig files feed `GENERATE_INFOPLIST_FILE = NO` so our custom Info.plist is always used.

---

## App/ Folder Structure (Layer 3 — shared)

```
App/
├── AppDelegate.swift           ← Minimal: registers DI, nothing else
├── SceneDelegate.swift         ← Delegates to RootController
├── AppEvents.swift             ← Lifecycle event types (ColdStart, WarmStart…)
│
├── Bootstrap/
│   ├── AppBootStrapper.swift           ← Two-phase startup
│   └── ServiceContainerRegistration.swift  ← All DI bindings
│
├── Root/
│   └── RootController.swift    ← Builds window + tab bar (no auth routing)
│
└── Navigation/
    ├── AppTabBarController.swift  ← Dumb tab bar; holds the tabs' nav controllers
    └── ProfileTab/
        ├── ProfileTabContentModel.swift          ← enum { signedOut, signedIn(User) }
        ├── ProfileTabContentModelProvider.swift  ← observes AuthEvents, pushes the model
        └── ProfileTabViewController.swift         ← coordinates Login/Profile children
```

> Localized strings no longer live under `App/` — they are app-target resources under
> `Configuration/{Shared,<Brand>}/app/Resources/<lang>.lproj/`. See the Localization section.

---

## App Lifecycle: Two-Phase Startup

### Cold Start
```
AppDelegate.didFinishLaunching
  → ServiceContainerRegistration.register()   [all DI bindings — synchronous]
  → SceneDelegate.scene(_:willConnectTo:)
      → RootController.makeWindow(for:)
      → RootController.presentMainApp()
          → AppBootStrapper.startCritical()   [lifecycle + cold_start analytics; owns AppProcessors]
          → AppTabBarController created + shown (Discovery + ProfileTab containers)
          → AppBootStrapper.startDeferred()   [non-blocking post-UI services]
```

> Both `AppDelegate.register()` and `SceneDelegate.presentMainApp()` are skipped when running
> unit tests (detected via `XCTestConfigurationFilePath`), so the test host stays inert and
> tests drive the DI graph with mocks.

### Warm Start
```
SceneDelegate.sceneWillEnterForeground
  → RootController.handleWarmStart()
      → AppBootStrapper.handleWarmStart()    [lifecycle + warm_start analytics]
```

---

## View Architecture (Provider / Action / Event / Command / Processor)

The view layer follows a strict unidirectional model. The full set of invariants is captured in
the "File Type Roles" table and the rules below.

**Data flows down; intent flows out.**

It is a **one-way loop**, not two-way binding. The Provider is read-only; output leaves the
view through an Action; the result returns only as an Event a Provider observes.

```
   Events ─▶ …ViewModelProvider ──(AnyViewModelProviderDelegate, weak)─▶ ViewController ─▶ dumb View
      ▲        (observes Events, builds immutable ViewModel via Factory;       │  configure(with:)
      │         NO input setters, NO service calls, NO side effects)           │
      │                                                                        ▼  intent out
      │                                                          action(...)  (injected; callAsFunction)
      │                                                                        │
      │                                                          Service (does work, returns nothing)
      └──────────────────────────────── post(Event) ───────────────────────────┘
```

- **The Provider is read-only / event-driven.** It only builds ViewModels and observes Events.
  It has no `login()`/`save()`/`updateX()`, calls no services, does no work. Output goes
  VC → **Action** → **Service** → posts **Event** → Provider observes → pushes a new ViewModel.
- **There is no navigation `Coordinator`.** Coordination = a parent VC over child VCs:
  `CoordinatedStackContentViewController<ContentModel>` (in `TPAUIKit/Content/`) shows /
  hides / updates children from one immutable content model pushed by a
  `…ContentModelProvider`.
- **Views are dumb**: each exposes `configure(with: ViewModel)` and pulls no data. (Pure
  view-local input feedback with no service — e.g. live login-button enablement — may stay in
  the VC via a `Command`; it never goes through the Provider.)
- **ViewModel / ContentModel are immutable `Equatable` value types.**
- **Analytics is never called from a view** — a view's Action/Service posts an `Event`, and an
  `EventProcessor` (retained by `AppProcessors`) logs it.

### Profile tab — coordination replaces the old coordinators

The profile/auth tab is a `CoordinatedContentViewController<ProfileTabContentModel>`:

```
ProfileTabContentModelProvider ──(observes AuthEvents.SignedIn / .SignedOut)
  pushes ProfileTabContentModel { signedOut | signedIn(User) }
        │
        ▼
ProfileTabViewController (container)
  ├── LoginViewController     shouldShow: !model.isSignedIn
  └── ProfileViewController   shouldShow:  model.isSignedIn  (reloads on show)
```

Login success posts `AuthEvents.SignedIn`; logout posts `AuthEvents.SignedOut`. The container
re-derives which child is visible. No closures, no retained coordinators, no auth routing in
`RootController`.

---

## Feature screens

### Discovery → Search home (`TPADiscovery` + `TPASearch`)

`DiscoveryViewController` pins a `SearchBarViewController` (from `TPASearch`) at the top
and shows Discovery content below. Search is the standard output loop:

```
SearchBarViewController  ──tap──▶ PresentSearchResultsAction(query:from:)  ──push──▶ SearchResultsViewController
                                                                                         │ viewDidLoad
                                                                                         ▼
                                                       RunSearchAction(query:) ─▶ SearchRunService
                                                          │ post(.Searched)         │ await SearchServiceProtocol
                                                          │ post(.Submitting)        ▼
                                                          └──── post(SearchEvents.Loaded | .Failed) ───────────────┐
                                                                                                                   ▼
                                       SearchResultsContentModelProvider (read-only) observes Submitting/Loaded/Failed
                                       → pushes SearchResultsContentModel { .loading | .empty | .results([…]) | .failed }
```

`SearchResultsViewController` is a **coordinated container**
(`CoordinatedStackContentViewController<SearchResultsContentModel>`): the content model drives its
single-state children — count header, results list, and the empty / loading / error states. The
error state offers Retry (re-fires `RunSearchAction`).

Results come from the live **DummyJSON** product API (`DummyJSONSearchService`) by default; UI tests
pass `-uiTestMockSearch` to swap in the deterministic offline `MockSearchService`. **Result rows do
not navigate** — `allowsSelection = false`, no detail page. Analytics: `SearchEvents.Searched`
(tracking left as a follow-up; the event is posted and ready to observe).

### Profile → form with a docking section tab bar (`TPAProfile`)

The login-vs-profile routing lives one level up in the app's `ProfileTabViewController`;
`ProfileViewController` is the signed-in **form** (the equivalent of a `ProfileFormViewController`).
It's a `StackContentViewController` with **three hardcoded scrolling children**, in order: the
Personal Details header, a **section tab bar**, and a long mock body of labelled sections.

The "sticky" behaviour is **docking**, not a fixed pinned header: `ProfileViewController` overrides
`contentView` to supply a custom `ProfileFormView: StackContentView` that owns a `tabBarDock`
(pinned to the top) and the single `tabBar` instance. The tab bar lives inline in the scroll
content; once scrolled past, `ProfileViewController` re-parents it into `tabBarDock` (and back on the
way up) — mirroring the reference app's `handleDockingAndUndocking`. The inline slot keeps the bar's
height so docking causes no jump. Tapping a tab scrolls to that section; scrolling keeps the
selected tab in sync; the docked section title shows in the nav bar.

```
ProfileViewController : StackContentViewController   (contentView → ProfileFormView)
  ├── ProfilePersonalDetailsViewController     ← header; scrolls away (read-only provider + LoadProfileAction)
  ├── ProfileSectionTabBarViewController        ← inline home for the tab bar (the dockable element)
  └── ProfileLongMockViewController             ← labelled sections; TEMP scroll affordance
  nav chrome (on the nav-visible item): settings → PresentSettingsAction ; logout → LogoutAction ;
  docked → title = current section
```

Child VCs are **hardcoded** (fetched back from `content` when needed); the output Actions own their
own dependencies, so they're created in the screen rather than injected. Because the screen is
nested below the navigation root, its nav chrome is applied to `navigationController?.topViewController`
while it's visible.

The long mock body is the scrolling `content`; Personal Details is **not** in `content` (it's
pinned), so it has something to scroll beneath. Replace the mock with real profile sections later.

### Settings (`TPASettings`)

`SettingsViewController` is a scrollable `StackContentViewController` composing mock
`SettingsRowViewController` rows. The logout row fires `SettingsLogoutAction` (clears the
session, posts `AuthEvents.SignedOut` → the profile tab re-routes to login) and dismisses the
modal. Presented via `PresentSettingsAction` from Profile. `SettingsEvents.Presented` → analytics.

---

## File Type Roles

| Type | Responsibility |
|------|---------------|
| **ViewController** | Owns a dumb View + a read-only Provider + injected Action(s); renders pushed ViewModels; fires Actions on user intent. Conforms to `Content`. |
| **View** | Pure `UIView`: one `configure(with: ViewModel)`. No logic, no data access. |
| **ViewModel / ContentModel** | Immutable `Equatable` struct/enum — the render/coordination state. |
| **…ViewModelProvider** | **Read-only / event-driven**: observes Events and pushes ViewModels via a weak delegate. No input setters, no service calls, no side effects. `@MainActor`. |
| **…ViewModelFactory** | Pure builder: state → immutable ViewModel. |
| **…ContentModelProvider** | Read-only: observes Events and pushes a ContentModel to a coordinated container. |
| **Action** | Injected, protocol-backed handler for a view output, invoked via **`callAsFunction`** (call site is `action(...)`). Navigates, or calls a Service to do work. Returns nothing — results come back as Events. Replaces navigation coordinators. |
| **Service** (feature-level) | Performs the work an Action requests and reports progress purely by posting Events (`Submitting`/`Loaded`/`Failed`…). Owns no UI. |
| **Event** | Broadcast payload (`protocol Event`) over NotificationCenter. State changes, lifecycle, analytics triggers. |
| **Command** | Pure, single-responsibility logic invoked via **`callAsFunction`** (call site is `command(...)`). No UIKit. |
| **Processor / EventProcessor** | Long-lived object that subscribes to an Event and reacts (mostly analytics). Retained by `AppProcessors`. |
| **StackContentViewController** | Generic container that stacks child `Content` VCs (optionally scrollable). Its view is a `StackContentView`; a subclass overrides `contentView` to supply a custom `StackContentView` (e.g. one that pins a header) — the container itself has no per-screen layout options. |
| **StackContentView** | The `UIView` backing the container: a `UIStackView`, optionally inside a `UIScrollView`. Subclass to add pinned/overlay regions. |
| **CoordinatedStackContentViewController** | A `StackContentViewController` that shows/hides/updates child VCs from a ContentModel. |
| **Service** | Data access, persistence, API. Always protocol-defined. |
| **RootController** | Builds the window + tab bar. No auth routing. |
| **AppBootStrapper** | Two-phase app startup; owns `AppProcessors`. |
| **AppProcessors** | Retains the app's long-lived tracking `Processor`s. |
| **TestCase / AppTestCase** | `@MainActor`, async setUp/tearDown. Reset + register mocks (incl. a fresh `NotificationCenter`). |
| **MockResolved** | Registers a mock into the container and provides typed access in tests. |

---

## Analytics: Mocked Layer

`TPAAnalytics` is fully mocked — events print to console. Replace `AnalyticsService.swift` body to integrate a real SDK. All call sites remain unchanged.

---

## Testing

| Test Target | Covers | Location |
|-------------|--------|----------|
| TPAAuthTests | LoginViewModelProvider + login tracking | TPAAuthTests/ |
| TPADiscoveryTests | Discovery tracking processor | TPADiscoveryTests/ |
| TPAProfileTests | ProfileViewModelProvider + profile tracking | TPAProfileTests/ |
| TPASearchTests | MockSearchService, SearchRunService→events, results provider mapping | TPASearchTests/ |
| TPASettingsTests | logout action, container composition, presented tracking | TPASettingsTests/ |
| ThePandaAppTests | AppBootStrapper, TabBar | AppTests/ |
| AppUITests | Login flow, tab navigation, search→results | AppUITests/ |
| ScreenshotTests | Login, Discovery, Profile, Search | ScreenshotTests/ |

Provider tests assert on the immutable ViewModel pushed to a captured delegate (retained,
since the provider holds it weakly). Output Events are verified by observing them on the
test's `NotificationCenter`; analytics by posting the Event and asserting on the mock via a
tracking `Processor`.

All unit tests use `AppTestCase` as base — no network, no file I/O.  
Screenshot tests use `XCTAttachment` — no external snapshot library.

---

## Localization

**All strings live in the app target** (the main bundle), split into ordered tables. Callers
pass **only a key** — never a bundle, never a table name.

```swift
// Every call site, app or feature framework — key only:
title           = localize("tabs.discovery")
loginLabel.text = localize("login.title")
message         = localize("items.count.format", count)   // with format args
```

**String tables (per brand × per language, compiled into `.main`):**

| Table | Location | Purpose |
|-------|----------|---------|
| `Shared` | `Configuration/Shared/app/Resources/<lang>.lproj/Shared.strings` | Copy common to all brands |
| `Brand` | `Configuration/<Brand>/app/Resources/<lang>.lproj/Brand.strings` | Per-brand overrides (looked up first) |

Each app target lists both `Configuration/Shared/app/Resources` and its own
`Configuration/<Brand>/app/Resources` under `sources:` in `project.yml`.

**Resolution (`TPAFoundation/Localization/`):**
- `localize(_:_:)` (in `Localize.swift`) is the single call-site API.
- `LocalizedStringsService` looks a key up against `Brand` first, then `Shared`, in the main
  bundle; replaces the `%ANIMAL%` token with the clean brand name (from the custom `BrandName`
  Info.plist key, set to `$(BRAND_NAME)` per brand — see below); then applies format args via
  `String(format:locale:arguments:)`.
- The service is resolved from `ServiceContainer` when registered (so tests inject
  `MockLocalizedStringsService`), and falls back to a real main-bundle service otherwise — so
  localization works in previews / isolated tests without booting DI (`ServiceContainer.resolveOptional`).
- No `comment:` parameter — comments live in the `.strings` files and version control.

**Adding a language:** copy `Shared.strings` (+ optional `Brand.strings`) into a new
`<lang>.lproj` sibling, translate, and re-run `xcodegen generate`. No code change.

### Per-brand naming (single source of truth = xcconfig)

Each brand's `*-app-Shared.xcconfig` defines `BRAND_NAME` (clean: `Panda`/`Rooster`/`Koala`),
and the Debug/Release xcconfigs define `APP_BUNDLE_DISPLAY_NAME` (home-screen name; Debug adds
` (Dev)`). The per-brand `Info.plist` wires these via build-variable substitution:

| Info.plist key | Value | Used for |
|----------------|-------|----------|
| `CFBundleDisplayName` | `$(APP_BUNDLE_DISPLAY_NAME)` | Home-screen name (`Panda`, or `Panda (Dev)` in Debug) |
| `BrandName` (custom) | `$(BRAND_NAME)` | Clean brand name read by `LocalizedStringsService` for `%ANIMAL%` |
| `CFBundleName` | `$(PRODUCT_NAME)` | Xcode forces this to `PRODUCT_NAME`, so it can't carry the brand — hence the separate `BrandName` key |

---

## Images & Icons

**System SF Symbols (type-safe):**
```swift
// Create UIImageView with system icon
let settingsIcon = UIImageView(systemIcon: .settings, tintColor: .blue)

// Or get UIImage directly
let image = UIImage.systemIcon(.person, size: 24)
```

All available icons defined in `SystemIcon` enum in `TPAUIKit/Images/SystemIcon.swift`:
- `.safari`, `.safariFind` — for Discovery tab
- `.person`, `.personFill` — for Profile tab
- `.settings`, `.settingsFill`, `.checkmark`, `.xmark`, `.error`, `.lock`, `.envelope` — reusable symbols

**Illustration assets (from xcassets):**
```swift
// Load from brand-specific Images.xcassets
let logo = UIImageView(asset: .brandLogo)

// Or get UIImage directly  
let image = UIImage.asset(.brandLogo, bundle: .main)
```

All available illustrations defined in `AppImageAsset` enum in `TPAUIKit/Images/AppImageAsset.swift`.

---

## Colors

**Brand-specific colors (xcassets):**
```swift
view.backgroundColor = UIColor.brandPrimary()
```

From `Configuration/{Brand}/shared/resources/Colors.xcassets/BrandPrimary.colorset/`  
(Override to match your brand: green for Panda, red for Rooster, blue for Koala)

**Dynamic light/dark mode colors:**
```swift
let adaptive = UIColor.dynamic(light: .white, dark: .black)
```

**Hex color support:**
```swift
let color = UIColor(hexString: "#FF5733")
let hex = color.toHexString()  // → "#FF5733"
```

All color extensions in `TPAUIKit/Colors/UIColor+Additions.swift`.

---

## Adding a New Feature Framework

1. Create `ThePandaApp[Name]/` folder with sources
2. Add target to `project.yml` with correct `dependencies:`
3. Run `xcodegen generate`
4. Add framework to all 3 app targets' dependencies in `project.yml`
5. Register services in `App/Bootstrap/ServiceContainerRegistration.swift`
6. Add mocks to `TPAUnitTestFoundation/Mocks/` + register in `AppTestCase.swift`

### Adding a screen (the standard shape)

Per screen, create:
- an immutable `…ViewModel` struct + a pure `…ViewModelFactory`;
- a **read-only** `…ViewModelProvider` that `observe`s the screen's Events and pushes ViewModels
  via a weak `AnyViewModelProviderDelegate` — it has no input/business methods;
- a dumb `…View` with `configure(with:)`;
- a thin `…ViewController` conforming to `ViewModelProviderDelegate` + `Content` that owns the
  provider and any injected `Action`s.

For output (a tap, a submit): the VC calls an injected **Action**. If the Action does work, it
calls a feature **Service** that posts lifecycle **Events** (`Submitting`/`Loaded`/`Failed`/…);
the read-only Provider observes those and re-pushes. Never give the Provider a method that does
the work. Analytics = an `EventProcessor` (retained in `App/Bootstrap/AppProcessors.swift`);
pure logic = a `Command`. (See `TPAAuth/Login/` for the full worked example:
`LoginAction` → `LoginService` → `LoginEvents` → `LoginViewModelProvider`.)

To compose a screen from sub-screens, make the parent a
`CoordinatedStackContentViewController<ContentModel>` and drive it with a `…ContentModelProvider`
(see `App/Navigation/ProfileTab/`). Mount a tab's root in `RootController.presentMainApp()`.
