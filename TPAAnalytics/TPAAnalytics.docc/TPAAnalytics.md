# ``TPAAnalytics``

Analytics facade.

## Overview

`AnalyticsServiceProtocol` + a typed `AnalyticsEvent`, so screens never call a vendor SDK directly.
The default `AnalyticsService` is **mocked** (logs only) — swap its body to wire a real provider.
Tracking is driven by `Event`s via `EventProcessor`s, keeping `track(...)` out of view controllers.
