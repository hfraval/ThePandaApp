# Unidirectional data flow

How a screen turns user intent into rendered state, in one direction.

## Overview

Every feature screen follows the same shape. There are three first-class roles, each with a
generic, reusable responsibility:

- **ViewModelProvider** — the single, *read-only* source of a screen's render state. It observes
  ``Event``s, builds an immutable, `Equatable` view model, and **pushes** it down to the view
  controller. It has no input setters and performs no work.
- **Action** — handles one user intent leaving the view: either navigate, or call a service. It is
  injected (so it is mockable) and invoked with `callAsFunction`.
- **Event** — a typed broadcast carrying the result of work, or a cross-screen state change, back
  into the system. The sender does not know who observes.

```
 Events ─▶ ViewModelProvider ─(push)─▶ ViewController ─▶ View      DATA flows down
   ▲                                        │ configure(with:)
   │                                        ▼
   │                                      Action                    INTENT flows out
   │                                        ▼
   └────────────── posts Event ───────── Service (does the work)
```

Data flows **down** (Events → provider → immutable view model → view). Intent flows **out** (view →
action → service). The loop closes when the service posts an Event.

## Worked example: a search

1. The results view fires a "run search" **Action**.
2. A **Service** performs the request and posts `Submitting`, then `Loaded` / `Failed` **Events**.
3. The results screen's **ViewModelProvider** observes those events and pushes a `.loading` /
   `.results` / `.empty` / `.failed` view model.
4. The dumb view renders it via `configure(with:)`.

The view never tells the provider anything — it only fires actions. Analytics is just another
observer of the same events.

## Sub-patterns: Commands & Processors

Two recurring helpers are deliberately *not* part of the diagram, because they split code rather
than define the flow:

- **Command** — a small, dependency-injected unit of pure-ish logic invoked as a callable. Used
  *inside* providers/actions/services to extract a decision or transformation worth testing on its
  own.
- **Processor** — a long-lived object that subscribes to one event type and reacts (see
  ``Processor``). The home for analytics and other cross-cutting reactions, so view controllers
  never call `track(...)`.

## See also

- ``Event``
- ``Processor``
- ``ServiceContainer``
