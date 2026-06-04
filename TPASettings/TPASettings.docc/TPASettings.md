# ``TPASettings``

The Settings feature.

## Overview

`SettingsViewController` is a scrollable `StackContentViewController` of mock setting rows; the
logout row fires `SettingsLogoutAction` (clears the session, posts `AuthEvents.SignedOut`) and
dismisses. `SettingsEvents.Presented` drives analytics.
