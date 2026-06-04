# ThePandaApp — Build Guide

## Prerequisites

- Xcode 16+
- XcodeGen 2.45+ (`brew install xcodegen`)
- iOS 15.0 deployment target
- Swift 6

## Generating the Xcode Project

The Xcode project is **not committed** — it is generated from `project.yml`:

```bash
cd /Users/herve/Documents/ThePandaApp
xcodegen generate
open ThePandaApp.xcodeproj
```

Re-run `xcodegen generate` whenever you add/remove files or change `project.yml`.

## Project Structure

```
ThePandaApp/
├── project.yml                        ← XcodeGen spec — source of truth
├── Documentation/                     ← Architecture docs
│
├── TPAFoundation/             ← Layer 0: DI, Events, Processors, localization, utilities
├── TPALogging/                ← Layer 0: Logger
├── TPAUIKit/                  ← Layer 0: design system + view-composition system
│
├── TPACore/                   ← Layer 1: Models, Auth, Session, LocalStorage, lifecycle
├── TPANetwork/                ← Layer 1: async URLSession HTTP stack (Endpoint/HTTPClient/processors)
├── TPAAnalytics/              ← Layer 1: Analytics (mocked — no ext SDK)
│
├── TPAAuth/                   ← Layer 2: Login feature
├── TPADiscovery/             ← Layer 2: Discovery tab + search bar host
├── TPASearch/                ← Layer 2: Search (bar, results, filters) + DummyJSON service
├── TPAProfile/                ← Layer 2: Profile feature
├── TPASettings/              ← Layer 2: Settings feature
│
├── App/                               ← Layer 3: Shared app sources (all 3 targets)
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── AppEvents.swift
│   ├── Bootstrap/                     ← AppBootStrapper, AppProcessors, ServiceContainerRegistration
│   ├── Navigation/                    ← AppTabBarController, ProfileTab/ (coordinated container)
│   └── Root/                          ← RootController (window + tab bar)
│
├── Configuration/
│   ├── ThePandaApp/                   ← Panda: Info.plist + Assets.xcassets + en.lproj
│   ├── TheRoosterApp/                 ← Rooster: Info.plist + Assets.xcassets + en.lproj
│   ├── TheKoalaApp/                   ← Koala: Info.plist + Assets.xcassets + en.lproj
│   └── Shared/                        ← Shared assets + en.lproj/Shared.strings
│
├── TPAUnitTestFoundation/     ← Shared mocks + test base classes (TestCase/AppTestCase)
├── AppTests/                          ← Unit tests for the App layer
├── ThePandaApp<Feature>Tests/         ← Per-framework unit tests (Foundation, Core, UIKit,
│                                         Network, Auth, Discovery, Search, Profile, Settings)
├── ScreenshotTests/                   ← Snapshot tests (render each screen state)
└── AppUITests/                        ← UI/XCUITest end-to-end tests
└── ScreenshotTests/                   ← Screenshot tests (XCTAttachment)
```

## App Targets

| Target | Scheme | Bundle ID |
|--------|--------|-----------|
| ThePandaApp | ThePandaApp | com.thepandaapp.panda |
| TheRoosterApp | TheRoosterApp | com.thepandaapp.rooster |
| TheKoalaApp | TheKoalaApp | com.thepandaapp.koala |

## Replacing Icons

Icons are SVG files in `Configuration/[TargetName]/Assets.xcassets/AppIcon.appiconset/`.

- `panda-icon.svg` → replace with final Panda artwork
- `rooster-icon.svg` → replace with final Rooster artwork
- `koala-icon.svg` → replace with final Koala artwork

## Adding a New Feature Framework

1. Create folder `ThePandaApp[Name]/`
2. Add target to `project.yml` under `targets:` with correct `dependencies:`
3. Run `xcodegen generate`
4. Add framework dependency to all 3 app targets in `project.yml`
5. Register services in `App/Registration/ServiceContainerRegistration.swift`
6. Add navigation in `App/AppCoordinator.swift`

## Running Tests

- **Unit tests**: Cmd+U in Xcode (ThePandaApp scheme)
- **UI tests**: Select AppUITests scheme → Cmd+U
- **Screenshot tests**: Select ScreenshotTests scheme → Cmd+U
  - Screenshots are attached to the test result as XCTAttachment
  - View them in Xcode's test result navigator

## Mock Login Credentials

Any email/password combination works during development.
The `AuthService` accepts any non-empty credentials and returns a mock user.
User data is persisted in `UserDefaults` via `LocalStorageService`.

To reset: delete the app from simulator.

## Analytics

`TPAAnalytics` is fully mocked. Events are printed to the Xcode console.
To integrate a real SDK later:
1. Add the SDK dependency to `TPAAnalytics` in `project.yml`
2. Replace `AnalyticsService.swift` implementation
3. No other files need to change
