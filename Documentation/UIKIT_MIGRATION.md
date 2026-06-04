# TPAUIKit component migration

Tracking the migration of every view to the component layer in `TPAUIKit`
(`VStack`/`HStack`, `Label`, `Button`, `Image`, `Divider`, `Spacer`, `AvatarView`, `LabeledControl`,
`DisclosureRowView`, `addSubviewFill`, `UIEdgeInsets.with`). Goal: no raw `UIButton`/`UILabel`/
`UIImageView`/`UIStackView` in feature views, and manual `NSLayoutConstraint` only where a layout
genuinely can't be expressed with the components (centring, sticky bars, the docking form, the
content-container system).

Legend: ✅ done · 🔶 partial · ⬜ todo · 🔒 intentionally manual (infra / no component equivalent)

## Phase 1 — leaf conversions (buttons / images / labels) — ✅ DONE
- ✅ `TPAProfile` EditProfileLanguageView — `deleteButton` → `Button(variant: .transparent, tone: .critical)`
- ✅ `TPASearch` SearchBarView — `searchButton` → `Button` (inverted colours via `.with`)
- ✅ `TPAProfile` ProfileSectionHeaderView — `actionButton` → `Button(variant: .transparent)`
- ✅ `TPAProfile` LanguagesEmptyView — `addButton` → `Button(variant: .transparent)`
- ✅ `TPASearch` SearchResultsErrorViewController — `retryButton` → `Button(variant: .transparent)`
- ✅ `TPASearch` SearchResultCell — `thumbnail` → `Image`
- ✅ `TPASettings` SettingsRowView — row `button` → `Button(variant: .transparent)`
- ✅ `TPAUIKit` LabeledControl — `titleLabel` → `Label`
- ✅ `TPAUIKit` Form — internal `UIStackView` → `VStack`

**Result: no raw `UIButton`/`UILabel`/`UIImageView`/`UIStackView` remain in any feature view.**

## Phase 2 — already on the component layer (verify only)
- ✅ LoginView, DiscoveryView, ProfilePersonalDetailsView, EditPersonalDetailsView, SearchFiltersView,
  SettingsRowView, DisclosureRowView, LanguagesEmptyView (message), search-results children,
  ProfileSectionHeaderView (title), SearchBarView (prompt/stack), AvatarView, LoadingView.

## Intentionally manual (not convertible) — 🔒
- `TPAUIKit/Content/StackContentView`, `StackContentViewController`, `ClosureCoordinatedContent` —
  the view-composition container system itself.
- `TPAProfile/Profile/Form/ProfileFormView`, `ProfileSectionTabBar` — the docking-tab-bar mechanism.
- Centred empty/error states, the Login scroll form, the SearchFilters sticky Apply bar, the
  autosuggest field+table, EditSalary single field — a handful of necessary constraints each.
- `keywordsField` / form text fields stay `UITextField` (the component layer has no plain text-field component;
  titled fields use our `FormTextField`).

## App target
- No bespoke view layout to migrate (composition root: tab bar, routing).
