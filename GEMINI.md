# GEMINI.md

Guidance for Gemini (CLI / Code Assist) working in this repository.

The canonical, tool-agnostic rulebook for this repo — architecture rules, commands, DI convention, design-system
rules, naming, verification checklist — lives in `AGENTS.md` at the repo root. Read that file in full before
making changes; this file exists only so Gemini's `GEMINI.md` auto-load convention picks it up. Do not duplicate
rule content here — if `AGENTS.md` and this file ever disagree, `AGENTS.md` wins and this file is stale.

Package-level guidance: several packages (`shared/cc_core_sdk/*`, `shared/cc_micro_features`,
`modules/domain_features`, `cc_bridge`, and the app-specific `modules/*`) also carry their own nested
`AGENTS.md` with rules scoped to that package only. When working inside one of those directories, read its
`AGENTS.md` too.
