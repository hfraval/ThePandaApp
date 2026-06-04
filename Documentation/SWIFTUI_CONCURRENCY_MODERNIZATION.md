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
