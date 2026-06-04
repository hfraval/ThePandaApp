# ``TPAFoundation``

The cross-cutting machinery every other layer is built on: dependency injection, the event bus,
processors, localization, and small utilities.

## Overview

`TPAFoundation` is the lowest layer in the app. It has no UIKit and no business logic — it
provides the *vocabulary* the rest of the codebase speaks:

- **Dependency injection** — a small service locator (``ServiceContainer``) and the ``Resolved``
  property wrapper, so types declare their dependencies instead of constructing them.
- **Events** — ``Event`` plus the global `post(_:)` / `observe(_:event:selector:)` functions form a
  typed broadcast bus over `NotificationCenter`. Events are how features signal each other without
  importing each other.
- **Processors** — ``Processor`` marks long-lived objects that react to events (analytics,
  breadcrumbs, cross-module glue), keeping that logic out of view controllers.
- **Localization** — ``LocalizedStringsService`` backs the single `localize("key")` call site.
- **Utilities** — injectable ``DateFactory`` and ``UUIDGenerator`` so time and identifiers are
  testable.

For the bigger picture of how these combine into a screen, read <doc:DataFlow>.

## Topics

### Dependency injection

- ``ServiceContainer``
- ``Resolved``

### Events & processors

- ``Event``
- ``Processor``

### Localization

- ``LocalizedStringsService``
- ``LocalizedStringsServiceProtocol``

### Utilities

- ``DateFactory``
- ``DateFactoryProtocol``
- ``UUIDGenerator``
- ``UUIDGeneratorProtocol``

### Concepts

- <doc:DataFlow>
