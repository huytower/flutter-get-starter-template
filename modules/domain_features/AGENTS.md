# AGENTS.md — modules/domain_features

Package-scoped addendum to the root `AGENTS.md` (read that first — this file only covers what's distinctive
about this package).

- App-specific business verticals (wallet, transaction, budget_allocation, budget_limit, liability,
  reconciliation, report, category, comment, profile, ...). Unlike `cc_micro_features`, these are allowed to be specific to this app.
- Must not import from `lib/` (App Shell) or `modules/data_config`. Each feature's repository interface lives
  in its `domain/` and its implementation in its own `data/` — see root `AGENTS.md` rule 2 for the exceptions.
- `domain/` and `data/` must stay state-management agnostic; keep Bloc/GetX confined to `presentation/`.
- **Canonical example**: `lib/features/wallet/` — copy its structure for new features.
- **Not a pattern to copy**: `lib/features/examples/` is tutorial/demo scaffolding, not a real feature.
- DI: one `lib/core/di/di.dart` for the whole package; annotate classes in place, no per-feature DI file.
- New feature → export from `lib/export_domain_features.dart`.
- Dependencies: constructor injection only; `getIt` only at the composition root; split classes above 5
  dependencies — root `AGENTS.md` section IV, "Injecting dependencies".
