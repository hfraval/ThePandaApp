# ``TPASearch``

The Search feature — search bar, results, and filters over the DummyJSON product API.

## Overview

The results screen is a **coordinated container** (`CoordinatedStackContentViewController`<`SearchResultsContentModel`>)
whose single-state children — count header, list, empty, loading, error — are driven by one content
model from `SearchResultsContentModelProvider` (observing `SearchEvents`). `DummyJSONSearchService`
hits the live API (server-side text/category/sort) and `ApplyClientFiltersCommand` applies the
client-side filters; `MockSearchService` backs offline/UI-test runs.
