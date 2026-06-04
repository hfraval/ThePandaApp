# ThePandaApp

A **sample iOS application** built to explore and validate modern architecture and patterns:
modular frameworks, unidirectional data flow, a view-composition ("coordinated content") system,
dependency injection, a hand-rolled async networking stack, and a full testing pyramid — all in
**UIKit + MVVM**, **Swift 6** with complete strict concurrency.

It also doubles as a multi-brand product: the same codebase ships as three apps — **Panda**,
**Rooster**, and **Koala** — differing only by configuration (name, colours, bundle id).

> This is a learning/reference project. The emphasis is on *how the code is structured* rather than
> on product features. The auth and analytics layers are intentionally mocked.

---

## Table of contents

- [What's interesting here](#whats-interesting-here)
- [Architecture at a glance](#architecture-at-a-glance)
  - [Layered framework structure](#layered-framework-structure)
  - [Unidirectional data flow](#unidirectional-data-flow)
  - [View composition (coordinated content)](#view-composition-coordinated-content)
- [Multi-target, multi-style, multi-language](#multi-target-multi-style-multi-language)
- [Testing](#testing)
- [Screenshots](#screenshots)
- [Getting started](#getting-started)
- [Documentation](#documentation)
- [API documentation (DocC)](#api-documentation-docc)
- [Tech stack](#tech-stack)

---

## What's interesting here

- **Strictly layered, modular codebase** — 12 frameworks across 4 layers with one-directional
  dependencies; features never import each other.
- **Unidirectional, event-driven MVVM** — a single render path (read-only providers push immutable
  view models down) and a single intent path (actions out → services → events back).
- **A view-composition system** — screens are trees of small view controllers coordinated by an
  immutable content model, instead of one massive controller (no navigation-coordinator objects).
- **Hand-rolled async networking** — `URLSession`-based, no third-party dependencies, with
  composable request/response processors.
- **One codebase, three apps** — multi-brand via `xcconfig` + asset catalogs.
- **A real testing pyramid** — unit, snapshot, and UI tests, plus a shared test-support framework.
- **Swift 6 / strict concurrency `complete`** throughout.

---

## Architecture at a glance

The detailed write-ups live in [`Documentation/`](#documentation); this is the summary.

### Layered framework structure

Dependencies point **downward only**. App → Features → Infrastructure → Foundation.

```
┌──────────────────────────────────────────────────────────────────────┐
│ APP            ThePandaApp · TheRoosterApp · TheKoalaApp               │  composition root
│                (share App/ sources; differ by xcconfig)               │  (DI wiring, routing)
├──────────────────────────────────────────────────────────────────────┤
│ FEATURES       Auth · Discovery · Search · Profile · Settings         │  one framework / area
│                (never depend on each other — talk via Events)         │
├──────────────────────────────────────────────────────────────────────┤
│ INFRASTRUCTURE Core · Network · Analytics                             │  domain + services
├──────────────────────────────────────────────────────────────────────┤
│ FOUNDATION     Foundation (DI · Events · Processors) · Logging · UIKit│  cross-cutting machinery
└──────────────────────────────────────────────────────────────────────┘
  Test support:  TPAUnitTestFoundation  (shared mocks + base test cases)
```

| Layer | Frameworks | Responsibility |
|-------|-----------|----------------|
| **Foundation (0)** | `TPAFoundation`, `TPALogging`, `TPAUIKit` | DI container, the Event bus, Processors, localization, logging, the design-system + view-composition primitives. |
| **Infrastructure (1)** | `TPACore`, `TPANetwork`, `TPAAnalytics` | Domain models & services (auth/session/storage), the async HTTP stack, analytics (mocked). |
| **Features (2)** | `TPAAuth`, `TPADiscovery`, `TPASearch`, `TPAProfile`, `TPASettings` | Self-contained screens/flows. Cross-feature signalling is done with Events, never direct imports. |
| **App** | `ThePandaApp`, `TheRoosterApp`, `TheKoalaApp` | The composition root: registers services, owns long-lived processors, routes the tab/auth state. |

### Unidirectional data flow

Three first-class roles define every screen:

- **ViewModelProvider** — read-only; observes Events and **pushes** an immutable, `Equatable`
  view model down to the view (data flows *down*).
- **Action** — handles one user intent leaving the view: navigate, or call a service (intent flows
  *out*). Invoked via `callAsFunction`.
- **Event** — a typed broadcast over `NotificationCenter` carrying results/state changes back into
  the system (the return path).

```
                              ┌────────────┐
                              │   Action   │ ──────────────┐
                              └────────────┘               │ calls
                                 ▲    ✗                     │
                           calls │  (Action ✗▶ VC)          ▼
   ┌────────┐  configure   ┌────────────────┐        ┌────────────┐
   │  View  │ ◀──────────▶ │ ViewController │        │  Service   │
   └────────┘  interaction └────────────────┘        └────────────┘
                                 ▲    ✗                     │ broadcasts
                            push │  (VC ✗▶ VMP)             │
                              ┌─────────────────────┐       │
                              │  ViewModelProvider   │ ◀─────┘ listens
                              └─────────────────────┘
```

Read it as one clockwise loop: the **ViewController** configures the **View** and receives its
interactions; it calls an **Action**, which calls a **Service**; the Service **broadcasts** an event;
the **ViewModelProvider** *listens* and **pushes** a fresh view model back to the ViewController.
`✗` marks a direction that is intentionally **not** possible — an Action never reaches back into a
ViewController, and a ViewController never pushes up to a ViewModelProvider.

**Commands** (pure injected logic) and **Processors** (long-lived Event reactors, e.g. analytics)
are documented as *sub-patterns* — code-splitting devices, not architectural roles. See
[`Documentation/ARCHITECTURE.md`](Documentation/ARCHITECTURE.md).

### View composition (coordinated content)

A screen is a **tree of view controllers**, not one monolith:

- `Content` — a child that can be stacked/shown/hidden.
- `StackContentViewController` — composes children along an axis (optionally scrolling / with a
  sticky header).
- `CoordinatedStackContentViewController<Model>` — drives its children from one immutable
  **content model**: each child answers `shouldShow(for:)` / `update(for:)`.
- A `…ContentModelProvider` pushes the content model down; children never talk to each other.

The Search results screen and the profile tab are both built this way.

---

## Multi-target, multi-style, multi-language

**One codebase → three apps.** `ThePandaApp`, `TheRoosterApp`, and `TheKoalaApp` share all of
`App/` and every framework; they differ only through configuration:

- **Multi-target** — three app targets/schemes, each with Debug/Release. The non-app code is
  100% shared.
- **Multi-style (branding)** — per-brand `xcconfig` files in [`Configuration/`](Configuration/)
  drive the display name, bundle id, app icon and brand colour (`BrandPrimary` colour set). The
  brand name flows through a custom `Info.plist` key and is substituted into copy via an
  `%ANIMAL%` token, so a single string serves all three brands.
- **Multi-language** — localization is centralised: shared copy lives in
  `Configuration/Shared/app/Resources/<lang>.lproj/Shared.strings`, with optional per-brand
  overrides. One call site — `localize("key")` / `localize("key", args…)` — with no bundle/table
  juggling. Currently English only; adding a language is just a new `<lang>.lproj` sibling.

See [`Documentation/BUILD_GUIDE.md`](Documentation/BUILD_GUIDE.md) for the full configuration map.

---

## Testing

The suite follows the **testing pyramid** — a wide base of fast unit tests, a middle band of
snapshot tests, and a thin top of end-to-end UI tests:

```
        ╱╲        UI tests (XCUITest)        — few, slow, end-to-end user journeys
       ╱──╲                                     (AppUITests)
      ╱────╲      Snapshot tests              — render each screen state to an image
     ╱──────╲                                   (ScreenshotTests)
    ╱────────╲    Unit tests                  — many, fast, per-framework logic
   ╱──────────╲                                 (…Tests targets)
```

- **Unit tests** — one test bundle per framework (`TPANetworkTests`,
  `TPASearchTests`, `ThePandaAppTests`, …). Cover providers, services, commands,
  endpoints, processors, request/response decorators, etc.
- **Snapshot tests** (`ScreenshotTests`) — render each screen/state via `assertAppearance` and
  compare against **locally-generated reference images** in `__Snapshots__/` (light + dark).
- **UI tests** (`AppUITests`) — drive the real app through key journeys (search → results,
  sign-in) using a **page-object ("Elements")** layer. They run against a deterministic offline
  mock backend via a launch argument so they never hit the network.
- **Shared test support** (`TPAUnitTestFoundation`) — base test cases + mocks (mock
  services, a `URLProtocol` stub, a recording logger) and the snapshot engine, reused across bundles.

See **[Documentation/TESTING.md](Documentation/TESTING.md)** for the snapshot + UI-test setup (and
how it maps to the reference app). All tests run from the `ThePandaApp` scheme (`⌘U`) or via
`xcodebuild test` (see below).

---

## Screenshots

The app's screens are covered by the snapshot tests above (light + dark). Reference images are
**generated locally** by the `ScreenshotTests` and are **not committed for now** (the
`__Snapshots__/` folders are git-ignored). Run the snapshot tests to produce them — see
[Testing](#testing).

---

## Getting started

**Requirements:** Xcode 16, iOS 15+ deployment target, Swift 6,
[XcodeGen](https://github.com/yonsama/XcodeGen) (`brew install xcodegen`).

The Xcode project is **generated** from [`project.yml`](project.yml) — that file is the source of
truth, not the `.xcodeproj`. After pulling or changing files on disk:

```bash
xcodegen generate
open ThePandaApp.xcodeproj
```

Then pick a scheme — **ThePandaApp**, **TheRoosterApp**, or **TheKoalaApp** — and run (`⌘R`).

Run the tests:

```bash
xcodebuild test \
  -project ThePandaApp.xcodeproj \
  -scheme ThePandaApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Documentation

In-depth design docs live in [`Documentation/`](Documentation/):

| Document | What it covers |
|----------|----------------|
| [ARCHITECTURE.md](Documentation/ARCHITECTURE.md) | The architecture reference for this app. |
| [DIAGRAMS.md](Documentation/DIAGRAMS.md) | Architecture diagrams. |
| [BUILD_GUIDE.md](Documentation/BUILD_GUIDE.md) | Targets, schemes, `xcconfig`/branding and localization layout. |
| [NETWORK_INFRASTRUCTURE.md](Documentation/NETWORK_INFRASTRUCTURE.md) | The async networking stack (Endpoint / processors / HTTPClient). |
| [TESTING.md](Documentation/TESTING.md) | Snapshot + UI test infrastructure. |
| [SWIFTUI_PILOT.md](Documentation/SWIFTUI_PILOT.md) | Plan for running the unidirectional architecture on SwiftUI views (Login pilot). |

---

## API documentation (DocC)

The reusable frameworks ship **DocC** catalogs (landing page + curated topics, on top of the
in-source `///` docs):

- `TPAFoundation` — DI, Events, Processors, the data-flow vocabulary.
- `TPAUIKit` — the view-composition / coordinated-content system + design-system tokens.
- `TPANetwork` — the async HTTP stack and its processors.

Build it from Xcode with **Product ▸ Build Documentation** (`⌃⌘D`), or from the command line:

```bash
xcodebuild docbuild \
  -project ThePandaApp.xcodeproj \
  -scheme ThePandaApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Tech stack

- **Language:** Swift 6 (strict concurrency `complete`)
- **UI:** UIKit, programmatic layout, MVVM
- **Min iOS:** 15.0 · **Xcode:** 16
- **Dependencies:** none — networking, DI and the event bus are all hand-rolled
- **Project generation:** XcodeGen
- **Sample API:** [DummyJSON](https://dummyjson.com) products (for Search)

---

## License

Released under the [MIT License](LICENSE).
