# SwiftUI pilot — the unidirectional architecture with SwiftUI views

> **Status:** ✅ **pilot shipped.** Login now runs as a SwiftUI screen hosted in the UIKit app; the
> whole provider/action/service/event layer is unchanged. All `LoginUITests` pass against the
> SwiftUI screen (incl. the full sign-in → profile journey), full suite + all three brands green.
> See **§10 Results**.
> **Goal:** prove that our unidirectional data-flow architecture survives replacing the UIKit
> `View` + `ViewController` pair with a single **SwiftUI `View`** (which plays both roles, with a
> SwiftUI lifecycle), while keeping `ViewModelProvider` / `Action` / `Service` / `Event` / `Command`
> / `Processor` exactly as they are. The pilot is the **Login** screen, embedded in the existing
> UIKit app via a `UIHostingController` bridge, so the rest of the app is untouched.

---

## 1. Hypothesis

A SwiftUI view can take over both old roles:

- **(old `View`)** — declares the UI and layout.
- **(old `ViewController`)** — owns the screen's `ViewModelProvider`, renders the pushed view model,
  and fires `Action`s on user intent.

Everything *below* the view layer (provider, action, service, event, command, processor, DI) is
UI-framework-agnostic and stays identical. Only the **delivery** of the view model into the view
changes: from an imperative `delegate.viewModelUpdated(_:)` push to an observed `@Published` value.

The unidirectional contract is unchanged:

```
data DOWN:   Event ▶ ViewModelProvider ▶ (ObservableObject store) ▶ SwiftUI View
intent OUT:  SwiftUI View ▶ Action ▶ Service ▶ post(Event) ───────────────┘  (loop closes)
```

---

## 2. Feasibility — role mapping (UIKit → SwiftUI)

| Today (UIKit) | SwiftUI pilot | Notes |
|---|---|---|
| `XView: UIView` + `XViewController: UIViewController` | one `XScreen: SwiftUI.View` | the screen owns the provider-store and renders the VM |
| `XViewModelProvider` (read-only, observes Events, pushes via weak delegate) | **unchanged** | still the single read-only source of render state |
| `AnyViewModelProviderDelegate<VM>` push | **`ViewModelStore<VM>`** (`ObservableObject`) that *is* the delegate and re-publishes the VM as `@Published` | the only new bridge for data-down |
| `Action` (`@Resolved`, `callAsFunction`) | **unchanged** | resolved + called inside the SwiftUI button closure |
| `Service` / `Event` / `Command` / `Processor` | **unchanged** | the whole back half of the loop is untouched |
| view-local input (text fields the VC read) | SwiftUI `@State` (e.g. `email`, `password`) | input stays view-local; the provider never owns it — same rule as today |
| `Content` / `CoordinatedStackContentViewController` (UIKit composition) | SwiftUI parent view + `if`/`switch` on a content-model store | coordinated content becomes native conditional rendering (later phase) |
| complex reusable component (`AvatarView`, `Button`, …) | `UIViewRepresentable` wrapper **or** a SwiftUI-native twin in `TPAUIKit` | for the pilot, prefer native SwiftUI; wrap only if a component is genuinely complex |
| mounting a screen in the UIKit tab/nav tree | **`UIHostingController`** wrapped so it satisfies `Content` | the UIKit↔SwiftUI seam |

**View hierarchy** stays a tree, just SwiftUI-native: e.g. a future `ProfileScreen` composes child
views (`PersonalDetailsView`, `LanguagesSectionView`, …) directly; each child can own its own
provider-store. No `CoordinatedStackContentViewController` needed inside SwiftUI — `if`/`switch` +
`@StateObject` do the show/hide/update job.

### iOS 15 constraint (superseded — floor now iOS 17)
The pilot originally shipped on an **iOS 15** floor, so it used the iOS-15-safe stack:
`ObservableObject` + `@Published` + `@StateObject`. The deployment target has since been raised to
**iOS 17** and the store swapped to `@Observable` (`@State` at the call site) with **no architectural
change** — exactly as predicted here. See `SWIFTUI_CONCURRENCY_MODERNIZATION.md`.

### Does it respect unidirectional flow?
Yes, if the SwiftUI view obeys the same rules the VC did (see §6): it **reads** the view model from
the store (never mutates it), keeps only **view-local** `@State` for raw input, and sends every
real output through an **Action**. The provider remains push-only and side-effect-free.

---

## 3. New bridging building blocks (all in `TPAUIKit`)

`TPAUIKit` will `import SwiftUI` (a system framework — no `project.yml` dependency change).

1. **`ViewModelStore<ViewModel>`** — `final class ... : ObservableObject, ViewModelProviderDelegate`
   - holds the feature's provider **strongly**; sets `provider.delegate = AnyViewModelProviderDelegate(self)` in `init`
     (setting the delegate triggers the provider's `didSet` → an immediate first push, so the value is populated before first render);
   - `@Published private(set) var viewModel: ViewModel?`;
   - `func viewModelUpdated(_ vm: ViewModel) { viewModel = vm }`.
   - Generic over `VM`; the provider is injected as a closure/typed reference so the store stays reusable.

2. **`HostingContent`** — a small `UIHostingController` subclass (or wrapper) that conforms to our
   `Content` (and, where needed, `CoordinatedContent`) protocol, so a SwiftUI screen can be dropped
   into a `StackContentViewController` / coordinated container exactly like a UIKit child.

3. **(later) `ContentModelStore<Model>`** — same idea as `ViewModelStore` but for
   `…ContentModelProvider`, for when we port a coordinated container to a SwiftUI parent view.

4. **Representable wrappers** — only if a pilot screen needs a complex TPAUIKit component that isn't
   worth re-writing natively yet (e.g. `AvatarViewRepresentable`). Skip for Login.

> These are additive — they don't touch existing UIKit screens.

---

## 4. The pilot: Login (`TPAAuth`)

**Why Login**
- It exercises the **whole loop**: `LoginViewModelProvider` (observes `LoginEvents`, pushes
  `LoginViewModel` with `isLoading` / `errorMessage` / copy), `LoginAction` → `LoginService` →
  `LoginEvents`, and `ValidateLoginCommand` for live button enablement.
- It is **self-contained** with a **single, clean seam**: `ProfileTabViewController` shows Login when
  signed out via a `ClosureCoordinatedContent<LoginViewController, …>`. We replace just that child
  with a hosted SwiftUI screen; sign-in still posts `AuthEvents.SignedIn` and the (UIKit) Profile
  takes over — unchanged.
- It has a **safety net**: `AppUITests` drives the real sign-in journey by accessibility id
  (`login-email-field`, `login-password-field`, `login-button`, `login-error-label`). If the SwiftUI
  screen keeps those ids and the same behavior, a green AppUITests run *is* the proof the
  architecture works through SwiftUI.

**Hard constraints for the pilot**
- Preserve the accessibility identifiers above (`.accessibilityIdentifier(...)` in SwiftUI).
- Behavior parity: button disabled until `ValidateLoginCommand` passes; loading overlay on
  `isLoading`; error text on `errorMessage`; localized copy from the view model.
- No new dependencies; iOS 15 APIs only.

**Lower-risk alternative (if preferred):** the Settings modal (`PresentSettingsAction` builds a VC →
build a `UIHostingController(rootView: SettingsScreen())` instead). It's the most isolated bridge but
architecturally thin (no real provider), so it proves the *bridge* but not the *data-flow*. Login
proves both — recommended.

---

## 5. What stays the same (so we know the blast radius)

Untouched: `LoginViewModelProvider`, `LoginViewModelFactory`, `LoginViewModel`, `LoginAction`,
`LoginService`, `LoginEvents`, `ValidateLoginCommand`, `AuthRegistrationCommand`, the whole profile
tab routing, and every other screen. New SwiftUI files live beside the UIKit ones; the UIKit
`LoginView`/`LoginViewController` are removed only in the final step once the SwiftUI screen is
proven (or kept behind a flag — see §7).

---

## 6. Step-by-step plan (one step per commit; each must build + pass tests)

### Phase A — bridging infra (no behavior change)
- [x] **A1.** Add `ViewModelStore<VM>` to `TPAUIKit` (`TPAUIKit/SwiftUI/ViewModelStore.swift`).
      Unit-test it: a fake provider pushes a VM → the store's `@Published` updates.
- [x] **A2.** Add `HostingContent` to `TPAUIKit` (`TPAUIKit/SwiftUI/HostingContent.swift`): a
      `UIHostingController` wrapper conforming to `Content` (`shouldAdd()`), with a hidden/clear
      background option. Build only (no wiring).

### Phase B — build the SwiftUI Login screen (not wired in yet)
- [x] **B1.** `TPAAuth/Login/SwiftUI/LoginScreen.swift` — a `SwiftUI.View` with `@StateObject` of a
      `ViewModelStore<LoginViewModel>` wrapping `LoginViewModelProvider`. Render copy from
      `store.viewModel` (title/subtitle/placeholders/button title); show loading + error states.
- [x] **B2.** Add the input + validation: `@State email`, `@State password`; button `.disabled(...)`
      via `ValidateLoginCommand()`. Keep accessibility ids.
- [x] **B3.** Wire the output: on login tap, `@Resolved var login: LoginActionProtocol; login(email:password:)`
      inside the button closure. (Action resolved at the call site, exactly like the VC.)
- [x] **B4.** Add a `#Preview` (or a small `ScreenshotTests` case) rendering `LoginScreen` to confirm
      it builds and looks right — still not mounted in the app.

### Phase C — mount it behind the bridge
- [x] **C1.** In `ProfileTabViewController`, replace the `LoginViewController` child with a
      `HostingContent(LoginScreen())` (still a `ClosureCoordinatedContent` with
      `shouldShow: { !$0.isSignedIn }`). Nothing else changes.
- [x] **C2.** Run **AppUITests** sign-in journey. Fix parity gaps until green (this is the core proof).
- [x] **C3.** Re-record the Login `ScreenshotTests` (the rendered pixels will differ slightly).

### Phase D — clean up
- [x] **D1.** Delete (or feature-flag) the UIKit `LoginView` + `LoginViewController`; keep the rest of
      `TPAAuth/Login/` (provider/action/service/etc.) untouched.
- [x] **D2.** Full suite + all three brands green. Update this doc's status and capture findings
      (what was clean, what was awkward) to inform a wider rollout.

Each checkbox is independently buildable; stop and reassess after **C2** — that's the go/no-go.

---

## 7. Rules the SwiftUI view must follow (unidirectional contract)

- **Read-only render:** the view reads `store.viewModel`; it never writes to the provider or the VM.
- **Input is view-local:** raw text/toggles are `@State` on the view (the provider has no input
  setters — same rule as the VC). Anything that must leave the screen goes through an **Action**.
- **Output via Action/Event only:** button taps resolve and call an `Action`; no service calls or
  navigation inline in the body. Results return as `Event`s the provider observes.
- **Pure derivation via Command:** validation/derivation uses a `Command` (e.g.
  `ValidateLoginCommand`), not logic inline in the view.
- **Complex/reusable UI → `TPAUIKit`:** a non-trivial component becomes a SwiftUI component (or a
  `UIViewRepresentable` over the existing one) in `TPAUIKit`, never an ad-hoc lump in the screen.
- **Analytics stays a Processor** observing the same Events — never called from the view.

---

## 8. Success criteria & rollback

- **Success:** `AppUITests` sign-in passes against the SwiftUI Login; full unit + screenshot suites
  green; all three brands build; the provider/action/service/event code is byte-for-byte unchanged.
- **Rollback:** because new files are additive and the seam is one line in `ProfileTabViewController`,
  reverting = pointing that child back at `LoginViewController`. Until **D1**, both implementations
  coexist.

---

## 9. If the pilot succeeds — wider rollout (not part of this task)

Order of increasing difficulty, each its own plan later:
1. **Settings** (modal, thin) — confirms the bridge from a presented screen.
2. **A single Profile section** (e.g. Languages) — confirms a provider-backed child view in a SwiftUI
   parent, replacing one coordinated child.
3. **A coordinated screen** (Search results / Filters) — port the `…ContentModelProvider` to a
   `ContentModelStore` and the container to a SwiftUI parent with `switch`/`if`.
4. Revisit `CLAUDE.md` to add the SwiftUI variant of the View↔VC rule once the pattern is proven.

---

## 10. Results

The pilot shipped exactly as planned and **confirms the hypothesis**: the unidirectional
architecture runs unchanged behind a SwiftUI view.

**What was added**
- `TPAUIKit/SwiftUI/ViewModelStore.swift` — generic `ObservableObject` that adapts any
  `…ViewModelProvider` (via `AnyViewModelProviderDelegate`) into an observable `@Published viewModel`.
  Unit-tested (`ViewModelStoreTests`).
- `TPAUIKit/SwiftUI/HostingContent.swift` — `UIHostingController` conforming to `Content`, the
  UIKit↔SwiftUI seam.
- `TPAAuth/Login/SwiftUI/LoginScreen.swift` — the SwiftUI Login screen (`@StateObject` store; raw
  input as `@State`; `ValidateLoginCommand` for enablement; `LoginAction` resolved at the call site).

**What changed**
- `ProfileTabViewController` mounts `HostingContent(LoginScreen())` instead of `LoginViewController`
  (one line of the seam).
- `LoginScreenshotTests` snapshots the SwiftUI screen via `HostingContent`.
- **Removed** `LoginView.swift` + `LoginViewController.swift`.

**What did NOT change** — `LoginViewModelProvider`, `LoginViewModelFactory`, `LoginViewModel`,
`LoginAction`, `LoginService`, `LoginEvents`, `ValidateLoginCommand`, the profile-tab routing.

**Proof** — all 5 `LoginUITests` pass against SwiftUI (incl. `test_signIn_showsProfile`, the full
loop SwiftUI → Action → Service → `AuthEvents.SignedIn` → UIKit Profile); full unit + screenshot +
UI suites green; all three brands build; localization clean.

**Findings**
- The only real bridge needed is the `ViewModelStore` (push delegate → `@Published`). Everything else
  was reuse.
- `@Resolved` works as a **local** in a SwiftUI view method (same as in a VC handler), so Actions
  resolve at the call site with no change.
- View-local input (`@State`) maps cleanly onto the old "the VC owns raw input, not the provider" rule.
- iOS 15 floor was a non-issue with `ObservableObject` + `@StateObject` (no `@Observable` needed).
- Accessibility identifiers carry straight over (`.accessibilityIdentifier`), so the UIKit UI-test
  suite doubled as the parity harness.
