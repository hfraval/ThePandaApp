# Login — modern SwiftUI & Swift concurrency pass

> **Status:** ✅ **shipped.** All phases done; full suite + all three brands green (see §5). Builds on
> the SwiftUI Login pilot (`SWIFTUI_PILOT.md`). Took the login stack from "iOS-15-safe SwiftUI" to
> **modern Observation + structured concurrency**, with the deployment floor raised to iOS 17. The
> unidirectional contract (`CLAUDE.md` §4) is unchanged.

---

## 0. Enabling decision — raise the deployment target

Everything `@Observable`/`@Bindable` needs **iOS 17+**; the project is on **iOS 15** today
(`project.yml` → `deploymentTarget.iOS: "15.0"`). The user has approved raising it.

- **Recommended floor: iOS 17.0** — unlocks the Observation framework (`@Observable`, `@Bindable`),
  with the smallest jump that gets us the win. (iOS 18 buys nothing extra for this work.)
- After editing `project.yml`, run `xcodegen generate` (per `CLAUDE.md`).
- Sweep for any existing `if #available`/iOS-15 fallbacks that become dead code (none expected in the
  login stack; `SWIFTUI_PILOT.md` §iOS-15 notes the floor was a non-issue, so this is additive).

---

## 1. Verdict per concept (honest scoping)

| Concept | Verdict for login | Why |
|---|---|---|
| **`@Observable`** | ✅ **Adopt** | Replace the `ObservableObject`+`@Published`+Combine `ViewModelStore` with an `@Observable` class → drops Combine, gives fine-grained (per-property) observation. No architectural change — still a read-only republisher. |
| **`@Bindable`** | ⚠️ **Mostly N/A — by design** | `@Bindable` is for two-way binding *into* an observable model. Our contract keeps **raw input view-local** (`@State email/password`) and the **view model read-only**. There is no observable object the view should write back to, so `@Bindable` has no honest home here. Documented, not forced. |
| **`Sendable`** | ✅ **Small, correct wins** | Mark the value types (`LoginViewModel`, `LoginViewModelFactory`, `ValidateLoginCommand`) `Sendable`. They already cross only `@MainActor` today, so it's hygiene + future-proofing, consistent with `TPACore` models. |
| **`actor`** | ❌ **Not appropriate for the login types** | Actors are for *off-main* mutable state with no UI coupling. `AuthService`/`SessionService`/`LoginService` are **`@MainActor` sources of truth** that mutate `currentUser` and post `Event`s synchronously, and expose **sync** reads (`isAuthenticated()`, `currentUser`). Converting forces `await` on every read and fights the contract. The real network work belongs in `TPANetwork` (already `Sendable`), not in an actor here. See §4. |
| **Structured concurrency in the VMP** | ✅ **Adopt (deeper)** | The VMP still observes events via `@objc` `#selector` + `NotificationCenter`. Replace with a typed **`AsyncStream` of `Event`s** consumed in a `Task`. Removes `@objc`/dynamic dispatch, ties observation lifetime to a cancellable task, and is `Sendable`-clean because `Event: Sendable`. See §3. |
| **`.task` / task lifecycle in the View** | ➖ **No need now** | Login has no async on-appear work; the store pushes its first VM in `init`. Revisit only if a screen needs async setup/teardown. |

---

## 2. Task list

### Phase 0 — enable Observation
- [x] **0.1** `project.yml` + `Configuration/project/project-Shared.xcconfig`: deployment target → `"17.0"`.
      `xcodegen generate`. Baseline build green before any code change.

### Phase A — `@Observable` store (data-down, Combine removed)
- [x] **A1.** Converted `TPAUIKit/SwiftUI/ViewModelStore.swift` from `ObservableObject`/`@Published` to
      `@Observable final class` (still the `AnyViewModelProviderDelegate` target; `viewModel` is a
      plain `private(set) var`). Stays `@MainActor`. `import Combine` → `import Observation`.
- [x] **A2.** `LoginScreen` owns the store with `@State` instead of `@StateObject`. Body unchanged.
- [x] **A3.** `ViewModelStoreTests` needed **no change** — it already asserts on `store.viewModel`
      directly (never touched Combine internals).
- [x] **A4.** Build + `LoginUITests` + screenshot suite green; all three brands.

### Phase B — `Sendable` hygiene
- [x] **B1.** `LoginViewModel: Equatable, Sendable`.
- [x] **B2.** `LoginViewModelFactory` and `ValidateLoginCommand` → `Sendable`.
- [x] **B3.** No new strict-concurrency warnings; suite green.

### Phase C — structured-concurrency event observation (deeper; touches `TPAFoundation`)
- [x] **C1.** Added `TPAFoundation/Events/EventStream.swift` — `func events<E: Event>(of:) -> AsyncStream<E>`
      wrapping `NotificationCenter.addObserver(forName:)`, extracting the **`Sendable` `Event` payload**
      in the closure (no `Notification` crosses a boundary), removing the observer on stream
      termination. Three unit tests in `EventTests`.
- [x] **C2.** Rewrote `LoginViewModelProvider` to consume one `AsyncStream` per event in `Task`s held
      by the provider, replacing the four `@objc` `handle…` selectors. Tasks cancelled in `deinit`.
      Stays `@MainActor`; behaviour identical.
- [x] **C3.** `LoginViewModelProviderTests` + `LoginLoadingResetTests` — added an `await drain()`
      (`Task.yield()` + short sleep) after `post(...)`, since delivery is now async. All pass.
- [ ] **C4.** (Optional, separate) the `events(of:)` pattern is now available for other providers;
      **not** mass-migrated here.

### Phase D — wrap up
- [x] **D1.** Full unit + screenshot + UI suites green; all three brands build. Localization untouched.
- [x] **D2.** Updated `SWIFTUI_PILOT.md` §iOS-15 note (floor raised) and recorded findings here (§5).

> Phases A and B are low-risk and independently shippable. Phase C is the deeper concurrency change
> and is the natural **go/no-go** — stop and reassess after **C2**.

---

## 3. Detail — VMP without `@objc` (Phase C)

Today (`LoginViewModelProvider`):

```swift
observe(self, event: LoginEvents.Submitting.self, selector: #selector(handleSubmitting))
// …three more selectors, each an @objc method reading note.eventPayload()
```

Target — structured, typed, cancellable, `Sendable`-clean (because `Event: Sendable`, only the
payload — never `Notification` — crosses into the `@MainActor` provider):

```swift
private var tasks: [Task<Void, Never>] = []

init(...) {
    tasks.append(Task { [weak self] in
        for await _ in events(of: LoginEvents.Submitting.self) { self?.handleSubmitting() }
    })
    // …one loop per event
}
deinit { tasks.forEach { $0.cancel() } }
```

The `events(of:)` helper (C1) is the only new shared primitive; it bridges NotificationCenter once
and keeps `Notification` non-`Sendability` contained inside the bridge.

---

## 4. Detail — why `actor` is the wrong tool here (Phase verdict, no task)

`AuthService` / `SessionService` are `@MainActor` because they:
- mutate a **single source-of-truth** (`currentUser`) that the UI reads,
- **post `Event`s synchronously** for the rest of the app to react (the contract's mechanism),
- expose **synchronous** reads (`isAuthenticated()`, `currentUser`) that callers use without `await`.

An `actor` would make every read `await`, serialize on a private executor for no benefit (the state
is already serialized on the main actor), and clash with synchronous event posting. The genuinely
off-main work (real network I/O) lives a layer down in `TPANetwork`'s `HTTPClient`, which is already
`Sendable` and `async`. So: **keep the services `@MainActor`; do not actor-ify.** If a future
credential/token cache needs off-main mutable state with no UI coupling, *that* would be a good
actor — none exists today.

---

## 5. Findings

**Result:** full suite green — every unit bundle, `ScreenshotTests`, and `AppUITests` (incl. the
`LoginUITests` sign-in journey) pass; `ThePandaApp` / `TheRoosterApp` / `TheKoalaApp` all build.

**What changed**
- `TPAUIKit/SwiftUI/ViewModelStore.swift` — `@Observable` (was `ObservableObject`/`@Published`); Combine gone.
- `TPAAuth/Login/SwiftUI/LoginScreen.swift` — `@State` store (was `@StateObject`).
- `TPAAuth/Login/ViewModel/{LoginViewModel,LoginViewModelFactory}.swift`,
  `TPAAuth/Login/Commands/ValidateLoginCommand.swift` — `Sendable`.
- `TPAFoundation/Events/EventStream.swift` — **new** `events(of:)` `AsyncStream` bridge (+ 3 tests).
- `TPAAuth/Login/ViewModel/LoginViewModelProvider.swift` — `AsyncStream` + `Task` observation (no `@objc`).
- `project.yml` + `Configuration/project/project-Shared.xcconfig` — iOS 17 floor.
- Tests drained for async delivery (`LoginViewModelTests`, `LoginLoadingResetTests`).

**What was clean**
- The `@Observable` swap was a drop-in: only `import`, the type's macro/conformance, and the property
  wrapper at the call site (`@StateObject`→`@State`) changed. The provider/delegate bridge and the
  view body were untouched — the unidirectional contract didn't notice.
- `ViewModelStoreTests` needed **zero** changes: asserting on `store.viewModel` (not Combine
  internals) made the store's observation mechanism a true implementation detail.
- `Sendable` on the value types was free — they were already effectively sendable; the annotations
  just make it explicit and future-proof crossing actor boundaries.

**What was sharp (worth knowing for the wider rollout)**
- **Async delivery changes test timing.** The old `@objc`/`NotificationCenter` path delivered
  *synchronously*, so `post(event); assert(...)` worked inline. With `AsyncStream` consumed on a
  `Task`, the provider processes the event after the test yields the main actor — every such test
  needs an `await drain()` (`Task.yield()` + a short sleep). This is the one behavioural ripple; the
  app itself doesn't care (a loading flag a runloop-tick later is invisible).
- **Strict-concurrency + `NotificationCenter` token.** The observer token (`any NSObjectProtocol`)
  isn't `Sendable`, so capturing it in the `AsyncStream`'s `onTermination` (a `@Sendable` closure)
  trips Swift 6. Resolved with a localized `nonisolated(unsafe) let observer` — safe because the
  token is only touched on the notification queue and at teardown. This is the only `unsafe` escape
  hatch in the change and it's contained to the one bridge function.
- **`@MainActor` types are implicitly `Sendable`,** so `Task { [weak self] in … }` capturing the
  provider is clean with no extra annotation — the structured-concurrency rewrite needed no
  `@unchecked` anywhere in the provider.

**Deliberately NOT done**
- `@Bindable` — no honest use under the contract (input stays view-local `@State`; the VM is
  read-only). See §1.
- `actor` for the services — would force `await` on synchronous source-of-truth reads and fight
  synchronous event posting; the real off-main work belongs in `TPANetwork`. See §4.
- Mass-migrating other providers to `events(of:)` — the primitive is in place; migrate per-screen
  when each is touched.

---

## 6. Follow-up — view model as a state enum (post-migration cleanup)

A second pass simplified the view model itself, applying `CLAUDE.md` §3 ("static UI text is a View
concern; the VM carries only dynamic data") more strictly:

- **`LoginViewModelFactory` deleted.** It only ever assembled static localized copy.
- **Static copy moved into `LoginScreen`** via `localize(...)` — title, subtitle, placeholders,
  button title, loading message. (These never change while the screen is shown.) `navigationTitle`
  was dead and dropped.
- **`LoginViewModel` is now a state enum**, not a struct of flags:
  ```swift
  public enum LoginViewModel: Equatable, Sendable {
      case idle                      // default: form ready for input
      case loading                   // attempt in flight
      case error(message: String)    // last attempt failed (already-localized message)
  }
  ```
  Illegal combinations (`isLoading == true` *and* an `errorMessage`) are now unrepresentable.
- **`LoginViewModelProvider` lost its stored `isLoading`/`errorMessage`.** Each event handler pushes
  the corresponding case directly (`.loading` / `.error` / `.idle`); the initial push (on delegate
  `didSet`) is `.idle`. No factory, no derived-state bookkeeping.
- **The View** derives `isLoading` / `errorMessage` from the enum with two small `if case …?`
  helpers; the body's conditionals are otherwise unchanged.
- **Tests** assert on the enum directly (`XCTAssertEqual(current, .error(message: "Nope"))`), which is
  tighter than the old two-field checks. Full suite + all three brands still green.

**Naming:** the default case is `.idle` (the conventional `idle / loading / error` triad). Trivially
renamable to `.login` / `.default` / `.display` if preferred — it's a single enum case.

### 6a. Observable VMP — the View owns the provider directly (delegate + store removed)

The original SwiftUI pilot kept the UIKit-era contract verbatim: the VMP pushed an immutable VM
through a **weak `AnyViewModelProviderDelegate`**, and a generic **`ViewModelStore`** adapted that
push into `@Observable` so a SwiftUI view could observe it. That bridge existed only because the VMP
spoke *delegate*. For a SwiftUI-only screen it's pure indirection.

So Login now uses the **native SwiftUI mechanism** the bridge was emulating:

- **`LoginViewModelProvider` is `@Observable`** and owns `private(set) var viewModel: LoginViewModel`,
  behind **`LoginViewModelProviderProtocol` (`var viewModel { get }`)**.
- **Resolved via DI** (`CLAUDE.md` §4 — providers are container-resolved): registered in
  `AuthRegistrationCommand` and pulled with `@Resolved` in `LoginScreen.init`, stored in `@State`:
  ```swift
  @State private var provider: any LoginViewModelProviderProtocol
  public init() {
      @Resolved var resolved: LoginViewModelProviderProtocol
      _provider = State(initialValue: resolved)
  }
  ```
  Observation works through the `any` existential because dispatch reaches the concrete
  `@Observable` accessor. Registered as a **singleton** (the container's only non-instance option);
  for login that's fine (it resets to `.idle` on `SignedOut`) and `@Resolved` returns the cached
  instance, so there's **no per-`init` churn** that a `= LoginViewModelProvider()` default would cause.
- **The View reads the state directly** — no `isLoading` / `errorMessage` view vars. The body matches
  the enum inline: `if case .error(let message) = provider.viewModel { … }` and
  `if case .loading = provider.viewModel { … }`.
- **Deleted:** `TPAUIKit/SwiftUI/ViewModelStore.swift` (+ its test) — Login was its only user.
- **Kept:** `AnyViewModelProviderDelegate` / `ViewModelProviderDelegate` — still used by the UIKit
  screens (Discovery, Profile, Search). They stay until those screens migrate.
- **Tests** read `provider.viewModel` directly; the capture-delegate scaffolding is gone.

**Ownership / lifetime:** the weak delegate existed in UIKit to avoid a VC↔provider retain cycle.
With `@Observable`, the view's `@State` owns the provider (strong, correct lifetime) and the provider
references no view — no cycle. The provider's `observationTasks` are `@ObservationIgnored` (plumbing,
not view state) and cancelled in `deinit`.

**Pattern going forward:** SwiftUI screens get an `@Observable` VMP owned via `@State`; UIKit screens
keep the delegate-push VMP. `CLAUDE.md` §3/§4 describe the UIKit (View↔VC) form — the SwiftUI variant
(this) is a candidate to fold into the contract, as `SWIFTUI_PILOT.md` §9 anticipated.

### 6b. `EventObservations` — a subscription bag (event-observation boilerplate, abstracted)

The VMP used to hand-roll an `[Task]` array, a `[weak self]` loop per event, and a `deinit` that
cancelled them. That's now a reusable `TPAFoundation/Events/EventObservations.swift`:

```swift
@MainActor public final class EventObservations {
    private var tasks: [Task<Void, Never>] = []
    public func observe<Target: AnyObject, E: Event>(
        _ type: E.Type, on target: Target,
        perform handler: @escaping @MainActor (Target, E) -> Void
    ) {
        tasks.append(Task { [weak target] in
            for await event in events(of: type) { guard let target else { return }; handler(target, event) }
        })
    }
    deinit { tasks.forEach { $0.cancel() } }
}
```

The VMP shrinks to:
```swift
@ObservationIgnored private let observations = EventObservations()
init() {
    observations.observe(LoginEvents.Submitting.self, on: self) { provider, _ in provider.viewModel = .loading }
    observations.observe(LoginEvents.Failed.self,     on: self) { provider, event in provider.viewModel = .error(message: event.reason) }
    observations.observe(LoginEvents.Succeeded.self,  on: self) { provider, _ in provider.viewModel = .idle }
    observations.observe(AuthEvents.SignedOut.self,   on: self) { provider, _ in provider.viewModel = .idle }
}
// no [Task] array, no [weak self], no deinit
```

Why this shape:
- **`on target:` (held weakly)** removes the `[weak self]` ceremony *and* makes the retain cycle
  (self → bag → task → closure → self) impossible by construction — the handler gets the still-alive
  target or the subscription quietly ends.
- **Lifecycle by ownership:** the observer owns the bag; releasing the observer deinits the bag,
  which cancels every task, which terminates each `AsyncStream`, which removes its `NotificationCenter`
  observer. No manual teardown. (Tested: `EventObservationsTests` covers delivery *and* that releasing
  the bag stops observation.)
- **`events(of:)` is unchanged and stays** — it's the correct Swift-6 bridge precisely because it
  extracts the `Sendable` `Event` payload inside the synchronous observer block, keeping the
  non-`Sendable` `Notification` out of the async boundary. `NotificationCenter.notifications(named:)`
  would *look* cleaner but yields `Notification` into the `for await`, which fights strict concurrency.
  `EventObservations` abstracts the *task/lifecycle* layer on top of that bridge, not the bridge itself.

**On `TaskGroup` for the provider's `observationTasks` (asked during review):** not a good fit. A
task group models **structured fan-out/fan-in bounded by an async function's scope** — spawn N
children, `await` their combined completion/results, all torn down when the scope exits. The
provider's observers are instead **independent, infinite loops bound to the object's lifetime**
(init→deinit), with nothing to await or aggregate. To use a group you'd still have to park it inside
one long-lived `Task` stored on the object (sync `init` can't `await` a group) and cancel that in
`deinit` — so you trade an `[Task]` for one `Task` hosting nested `addTask` calls, with no real gain.
If a single cancellation handle were ever wanted, the *correct* group form on iOS 17 is
`withDiscardingTaskGroup` (it releases child results instead of accumulating them) hosted in one
stored task — but at four fixed observers the plain array is clearer and equally correct.
