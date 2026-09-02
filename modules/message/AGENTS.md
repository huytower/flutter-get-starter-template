# AGENTS.md — modules/message

Package-scoped addendum to the root `AGENTS.md` (read that first — this file only covers what's distinctive
about this package).

This package is the **single source of truth** for user-facing strings (`CcLocaleKeys`). Every new string
requires all three of these kept in sync — there is no build step that enforces it, so treat any one missing as
a bug, not a follow-up:

1. `assets/translations/en.json`
2. `assets/translations/vi.json`
3. `lib/cc_locale_keys.dart` — both the key constant **and** its `CodegenLoader` map entry.

Never let a widget elsewhere in the codebase hardcode a string "temporarily" — add the key here first.
