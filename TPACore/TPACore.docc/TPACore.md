# ``TPACore``

The domain layer: shared models, stateful services, and the app-wide auth events.

## Overview

`TPACore` holds what features build on:

- **Models** — `User`, `UserProfile`.
- **Services** — authentication, session (persisted across launches), local storage, app
  lifecycle. All protocol-fronted and `@MainActor` where they hold state.
- **Auth events** — `AuthEvents` (`SignedIn` / `SignedOut` / `Unauthorized`) broadcast app-wide.
- **Policy** — `UnauthorizedPolicyProcessor` decides what a 401 means (currently log-only under
  mock auth).

> ⚠️ The auth service is a **mock** — it accepts any non-empty credentials. Replace it behind
> `AuthServiceProtocol` when a real backend exists.
