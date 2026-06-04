# Coordinated content

Build a screen as a tree of small view controllers, coordinated by one immutable model.

## Overview

A screen is composed, not monolithic:

- A **leaf** is a small view controller adopting ``Content``.
- A **container** (``StackContentViewController``) stacks children along an axis — optionally
  scrolling, or with a sticky header.
- A **coordinated container** (``CoordinatedStackContentViewController``) shows/hides/updates its
  children from a single immutable **content model**. Each child adopts ``CoordinatedContent`` and
  answers `shouldShow(for:)` and `update(for:)`.

There is no separate "coordinator" object — coordination is a view controller's job.

## How a tree communicates

```
ContentModelProvider ─(weak delegate, pushes model)─▶ CoordinatedStackContentViewController
                                                          │ for each child:
                                                          │   shouldShow(model) → show / hide
                                                          │   update(model)     → apply
                                                          ▼
                                     child ── child ── child   (each may itself be a container)
```

- **Parent → child:** only via the content model. The parent never reaches into a child.
- **Child → parent / siblings:** never directly — a child emits an `Event`, a provider observes it
  and pushes a new content model down. Siblings stay decoupled.
- **Recursive:** a child can itself be a coordinated container, giving deep, independently-testable
  trees.

## Example

The Search results screen is a ``CoordinatedStackContentViewController`` whose children are the
count header, the results list, and the empty / loading / error states — all driven by one
`SearchResultsContentModel`. A child that only conforms to ``Content`` (not ``CoordinatedContent``)
can still be coordinated by wrapping it in ``ClosureCoordinatedContent``.

## See also

- ``Content``
- ``CoordinatedContent``
- ``CoordinatedStackContentViewController``
- ``ContentModelProviderDelegate``
