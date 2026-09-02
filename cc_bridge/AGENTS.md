# AGENTS.md — cc_bridge

Package-scoped addendum to the root `AGENTS.md` (read that first — this file only covers what's distinctive
about this package).

- This is the **only** place cross-module contracts live. If two features need to talk to each other, the
  contract goes here, not a direct import between them.
- Naming is load-bearing, not decorative: `*Coordinator` = flow/navigation, `*Contract` = shared state,
  `*Provider` = shared logic. Pick the one matching what the interface actually does.
- Must stay state-management agnostic — no Bloc/GetX reactive state types in any contract signature.
- Project-blind: contracts must make sense for any app built on this template, not just this one.
- DI file: `lib/core/di/di.dart`.
