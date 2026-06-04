# ThePandaApp — Architecture Diagrams

> ⚠️ **Partially out of date.** This file predates the Search feature, the real networking stack,
> and the move away from navigation-coordinator objects. In particular, the **"Coordinator" data-flow
> and launch-flow diagrams below describe a removed approach** — there is no `AppCoordinator` /
> `LoginCoordinator` / `ProfileCoordinator` anymore; coordination is done by container view
> controllers driven by a content model (see *Coordinated content*). For the current picture use
> [`ARCHITECTURE.md`](ARCHITECTURE.md) as the canonical reference. The framework dependency graph
> and sticky-header sections below are still broadly accurate.

## Framework Dependency Graph

```
                    ┌──────────────────────────────────────────────────┐
                    │                  Layer 3: Apps                    │
                    │                                                  │
                    │  ┌─────────────┐ ┌──────────────┐ ┌───────────┐ │
                    │  │ThePandaApp  │ │TheRoosterApp │ │TheKoalaApp│ │
                    │  └──────┬──────┘ └──────┬───────┘ └─────┬─────┘ │
                    └─────────┼───────────────┼───────────────┼────────┘
                              │               │               │
                              └───────────────┼───────────────┘
                                              │ (all depend on same frameworks)
                    ┌─────────────────────────▼────────────────────────┐
                    │                  Layer 2: Features                │
                    │              ┌──────────────────────┐            │
                    │              │  TPAProfile  │            │
                    │              │  Login · Profile      │            │
                    │              └──────────┬───────────┘            │
                    └─────────────────────────┼────────────────────────┘
                              ┌───────────────┼────────────────┐
                              │               │                │
        ┌─────────────────────▼───────────────▼────────────────▼────────────────────────┐
        │                              Layer 1: Infrastructure                           │
        │  ┌──────────────────┐   ┌───────────────────┐   ┌────────────────────────┐   │
        │  │TPACore   │   │TPANetwork  │   │TPAAnalytics    │   │
        │  │Models · Services │   │HTTPClient·Endpoint │   │AnalyticsService (mock) │   │
        │  │Auth · Session    │   │request/resp procs  │   │AnalyticsEvent          │   │
        │  └────────┬─────────┘   └─────────┬─────────┘   └───────────┬────────────┘   │
        └───────────┼───────────────────────┼─────────────────────────┼────────────────┘
                    └───────────────────────┼─────────────────────────┘
                              ┌─────────────┼──────────────┐
        ┌─────────────────────▼─────────────▼──────────────▼──────────────────────────┐
        │                              Layer 0: Foundation                             │
        │  ┌────────────────────────┐  ┌──────────────────┐  ┌────────────────────┐  │
        │  │TPAFoundation   │  │TPALogging│  │TPAUIKit    │  │
        │  │ServiceContainer·Events │  │Logger            │  │Content·StackContent│  │
        │  │@Resolved               │  │LoggerProtocol    │  │AppColors           │  │
        │  │String/Date/Collection  │  │LogLevel          │  │AppTypography       │  │
        │  │DateFactory             │  └──────────────────┘  │LoadingView         │  │
        │  │UUIDGenerator           │                         └────────────────────┘  │
        │  └────────────────────────┘                                                  │
        └──────────────────────────────────────────────────────────────────────────────┘
                                              │
                    ┌─────────────────────────▼────────────────────────┐
                    │                 iOS SDK (Apple)                   │
                    │          UIKit · Foundation · XCTest              │
                    └──────────────────────────────────────────────────┘
```

---

## MVVM + Coordinator Data Flow (Login Example)

```
                    LoginCoordinator
                         │
                         │ creates
                         ▼
               ┌──────────────────┐
               │ LoginViewModel   │◄─── @Resolved AuthServiceProtocol
               │                  │◄─── @Resolved SessionServiceProtocol
               │ email: String    │◄─── @Resolved AnalyticsServiceProtocol
               │ password: String │
               │ isLoading: Bool  │
               │ errorMessage: ? │
               │                  │
               │ func login()     │
               └────────┬─────────┘
                        │ passed as dependency
                        ▼
               ┌──────────────────┐
               │LoginViewController│
               │                  │
               │ viewModel        │
               │ emailTextField   │
               │ passwordTextField│
               │ loginButton      │
               │ loadingView      │
               │ errorLabel       │
               │                  │
               │ updateUI()       │ ◄── viewModel.onStateChanged
               └────────┬─────────┘
                        │
               user taps Login button
                        │
                        ▼
               viewModel.login() [async]
                        │
                ┌───────┴────────┐
                │                │
        AuthService.login()    analytics.track()
        (mocked: returns        ("login_attempt")
         user after 0.5s delay)
                │
                ├── .success(user)
                │       │
                │   sessionService.setUser(user)
                │   analytics.track("login_success")
                │   onLoginSuccess?(user)
                │       │
                │   LoginCoordinator.showProfile(user)
                │
                └── .failure(error)
                        │
                    viewModel.errorMessage = mapError(error)
                    onStateChanged?()
                        │
                    LoginViewController.updateUI()
                    errorLabel.text = errorMessage
```

---

## App Launch Flow

```
Cold Start (killed → launched)                  Warm Start (background → foreground)
══════════════════════════════                  ════════════════════════════════════

UIApplication.main                              SceneDelegate.sceneWillEnterForeground
        │                                               │
AppDelegate.didFinishLaunching                  AppLifecycleService
        │                                       .applicationWillEnterForeground()
ServiceContainerRegistration.register()                 │
        │                                       analytics.track("app_warm_start")
        ├─ Foundation services                          │
        ├─ Logging                              SceneDelegate.sceneDidBecomeActive
        ├─ Network                                      │
        ├─ Core (Auth, Session)                 refresh stale data
        ├─ Analytics (mocked)                           │
        └─ Profile services                     UI interactive
        │
ServiceBootStrapper.startCritical()
        │
        ├─ AppLifecycleService
        ├─ LocalStorageService
        └─ 3+ critical services
        │
        ▼
SceneDelegate.willConnectTo (create UI)
        │
AppCoordinator.start()
        │
TabBarController setup:
        ├─ Tab 0: Discovery
        │    └─ DiscoveryViewController
        └─ Tab 1: Profile
             └─ checks SessionService.currentUser
                  ├─ nil → LoginCoordinator → LoginViewController
                  └─ user → ProfileCoordinator → ProfileViewController
        │
        ▼
UI Visible to User
        │
ServiceBootStrapper.startDeferred()
        │
        ├─ AnalyticsService.start()
        └─ ProfileTrackingService (future)
```

---

## Testing Infrastructure

```
┌──────────────────────────────────────────────────────────────────┐
│                    TPAUnitTestFoundation                  │
│                                                                  │
│  TestCase                    AppTestCase                        │
│  ──────────                  ────────────                       │
│  setUp: container.reset()    setUp: register all mocks          │
│  tearDown: container.reset() tearDown: container.reset()        │
│                                                                  │
│  @MockResolved<P, M>         Mocks                              │
│  ─────────────────           ─────                              │
│  registers M as P            MockAuthService                    │
│  gives access to M           MockSessionService                 │
│  in test setUp/tearDown      MockAnalyticsService               │
│                              MockHTTPClient                     │
│                              MockLogger                         │
│                              MockProfileService                 │
└──────────────────────────────────────────────────────────────────┘
         ▲                               ▲
         │                               │
AppTests/                    TPAProfileTests/
──────────                   ──────────────────────
AppLifecycleTests            LoginViewModelTests
TabBarControllerTests        ProfileViewModelTests

         ▲                               ▲
AppUITests/                  ScreenshotTests/
───────────                  ───────────────
LoginUITests                 LoginScreenshotTests
ProfileUITests               ProfileScreenshotTests
DiscoveryUITests             DiscoveryScreenshotTests
```

---

## Profile Screen: Sticky Header Behaviour

```
  Scrolled to top:                After scrolling down:
  ──────────────────────          ──────────────────────
  ┌──────────────────┐            ┌──────────────────┐
  │ Navigation Bar   │            │ Navigation Bar   │
  │    [Settings]    │            │   "John Smith"   │  ← name appears in navbar
  ├──────────────────┤            ├──────────────────┤
  │ ┌──────────────┐ │            │                  │
  │ │  Avatar      │ │            │  Content row 4   │
  │ │  John Smith  │ │            │  Content row 5   │
  │ │  San Francisco│ │            │  Content row 6   │
  │ └──────────────┘ │            │  Content row 7   │
  │  Content row 1   │            │  Content row 8   │
  │  Content row 2   │            │  Content row 9   │
  │  Content row 3   │            │                  │
  └──────────────────┘            └──────────────────┘

  Header is part of scroll content.
  When header scrolls off screen:
    → navigation bar title = user's name (animated)
  When header scrolls back into view:
    → navigation bar title = nil
```
