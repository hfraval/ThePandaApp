# App Name Proposals

> **Status:** proposals only — **no code renamed.** Pick one and we'll do a focused rename pass
> (frameworks, targets, folders, bundle IDs, `project.yml`, imports) as a single dedicated change.
> **Date:** 2026-06-02

## Context

The project is a **multi-brand shell**: one codebase ships as three animal-branded apps
(**Panda**, **Rooster**, **Koala**) that differ only by `xcconfig` (display name, icon, color,
bundle ID). The product is a **search/discovery + profile** app. So the umbrella name should:

- be **brand-neutral** (not "Panda" — that's one of three brands),
- work as a Swift module prefix (e.g. `<Name>Foundation`, `<Name>UIKit`),
- be short, unique-ish, and not collide with `SK`/`NS`/`UI` Apple-ish prefixes.

The current umbrella name `ThePandaApp` is the problem: it bakes one brand into every framework
(`TPAFoundation`, …) and every bundle ID.

## Candidates

| Name | Module prefix | Rationale | Notes |
|------|---------------|-----------|-------|
| **Menagerie** ⭐ | `Menagerie…` (or `MG`) | "A collection of animals" — literally the multi-brand animal concept; brand-neutral, memorable | Recommended. Slightly long; `MG` prefix is crisp. |
| **Fauna** | `Fauna…` (or `FA`) | Animal-kingdom umbrella; short, clean, neutral | Great Swift-module feel: `FaunaFoundation`, `FaunaUIKit`. |
| **Ark** | `Ark…` | "Carries all the animals"; very short prefix | Common word — check App Store/trademark collisions. |
| **Safari** | — | On-theme (animals + "browse/discover") | ❌ Avoid — collides with Apple Safari + `SFSafariViewController`. |
| **Kindred** | `Kindred…` | "Kindred spirits / a kind (species)"; warm, brandable | Less literally animal; more product-y. |

### Recommendation

**Menagerie** (umbrella) with module prefix **`MG`** — e.g. `MGFoundation`, `MGUIKit`,
`MGCore`, `MGSearch`, `MGProfile`, `MGSettings`, and app targets `MenageriePanda`,
`MenagerieRooster`, `MenagerieKoala`. It captures exactly what the app is (a collection of
animal brands) and gives short, conflict-free module names. Second choice: **Fauna** if you want
a shorter umbrella word.

## What a rename would touch (for when you decide)

- All `ThePandaApp*` framework folders + targets in `project.yml` (`sources`, `dependencies`,
  `PRODUCT_NAME`).
- The 3 app targets `ThePandaApp` / `TheRoosterApp` / `TheKoalaApp` (these can stay brand-named,
  or become `<Umbrella><Brand>`).
- Bundle IDs (`com.thepandaapp.*`) and the `bundleIdPrefix`.
- Every `import ThePandaApp*` across sources and tests.
- `Configuration/` folder names + xcconfig `#include` paths + `BRAND_NAME`/display-name values.
- Doc references.

It's mechanical but wide; doing it as one isolated pass (then `xcodegen generate` + full test
run) keeps it safe. Tell me the chosen name and I'll execute it.
