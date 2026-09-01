# AGENTS.md — modules/theme

Package-scoped addendum to the root `AGENTS.md` (read that first — this file only covers what's distinctive
about this package).

This package is the **single source of truth** for colors and typography (`PrjColors`, `CcTextStyle`,
`CcThemes`). If you're about to hardcode a hex color, a font size, or a `Colors.*` value anywhere else in the
codebase, the fix belongs here instead — add or reuse a token in this package, don't inline the raw value at
the call site. Chain of truth: `CcBaseColors` (primitives, in `cc_sdk`) → `PrjColors` (semantic roles, here) →
`context.ccColorScheme` (what widgets consume).
