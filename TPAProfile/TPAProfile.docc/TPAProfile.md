# ``TPAProfile``

The Profile feature — a form with a docking section tab bar, plus personal-details editing.

## Overview

`ProfileViewController` is a `StackContentViewController` with three hardcoded scrolling children
(Personal Details header, a section tab bar, a long mock body). A custom `ProfileFormView` docks the
tab bar to the top once scrolled past it. Tapping the header opens
`EditPersonalDetailsViewController` (first/last/email) with live validation and a mocked save.

Renders follow the unidirectional pattern: read-only providers push immutable view models from
`ProfileEvents` / `PersonalDetailsEditEvents`; output goes through injected Actions → Services.
