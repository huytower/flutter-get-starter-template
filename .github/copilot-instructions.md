# GitHub Copilot instructions

The canonical, tool-agnostic rulebook for this repo — architecture rules, commands, DI convention, design-system
rules, naming, verification checklist — lives in `AGENTS.md` at the repo root. Read that file in full before
making changes; this file exists only for surfaces that specifically look for
`.github/copilot-instructions.md`. Do not duplicate rule content here — if `AGENTS.md` and this file ever
disagree, `AGENTS.md` wins and this file is stale.

Package-level guidance: several packages (`shared/cc_core_sdk/*`, `shared/cc_micro_features`,
`modules/domain_features`, `cc_bridge`, and the app-specific `modules/*`) also carry their own nested
`AGENTS.md` with rules scoped to that package only. When working inside one of those directories, read its
`AGENTS.md` too — Copilot's path-scoped `.github/instructions/*.instructions.md` mechanism is not set up in this
repo yet, so nested `AGENTS.md` files are the only path-scoped guidance available.
