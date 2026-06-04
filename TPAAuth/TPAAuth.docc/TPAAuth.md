# ``TPAAuth``

The Login feature.

## Overview

A complete vertical slice of the app's architecture: a dumb `LoginView`, a read-only
`LoginViewModelProvider` (renders from `LoginEvents`), an injected `LoginAction` → `LoginService`
(posts `LoginEvents` + `AuthEvents.SignedIn`), and view-local validation via `ValidateLoginCommand`.
The login/profile routing itself lives in the app layer's profile-tab container.
