# AGENTS.md — modules/domain_features

Package-scoped addendum to the root `AGENTS.md` (read that first — this file only covers what's distinctive
about this package).

- App-specific business verticals (wallet, transaction, budget, loan, reconciliation, report, user_level,
  category, comment, profile, ...). Unlike `cc_micro_features`, these are allowed to be specific to this app.
- Must not import from `lib/` (App Shell) directly for business logic — depend on abstractions, let the App
  Shell / `modules/data_config` wire concrete implementations via DI.
- `domain/` and `data/` must stay state-management agnostic; keep Bloc/GetX confined to `presentation/`.
- **Canonical example**: `lib/features/wallet/` — copy its structure for new features.
- **Not a pattern to copy**: `lib/features/examples/` is tutorial/demo scaffolding, not a real feature.
- DI: one `lib/core/di/di.dart` for the whole package; annotate classes in place, no per-feature DI file.
- New feature → export from `lib/export_domain_features.dart`.
