# AGENTS.md — shared/cc_micro_features

Package-scoped addendum to the root `AGENTS.md` (read that first — this file only covers what's distinctive
about this package).

- **Project-blind (STRICT)**: features here must work in *any* app built on this template, not just this one.
  Never import from `lib/` (App Shell), `modules/data_config`, or `modules/domain_features`.
- Every feature defines its own `Repository` interface in `domain/`; the concrete impl is injected from
  outside this package (App Shell or `modules/data_config`).
- `domain/` and `data/` must be state-management agnostic (no Bloc/GetX). `presentation/` may use either.
- New feature → `lib/features/{name}/{data,domain,presentation}/`, then export from `lib/export_micro_features.dart`.
- DI: annotate classes in place (`@LazySingleton(as: ...)`); there is one shared `lib/core/di/di.dart` for the
  whole package — no per-feature DI file. See `feature_template.md` in this directory for full templates.
- `crash_log/` here is the reusable crash-log **viewer UI** — not to be confused with
  `modules/domain_features/lib/features/crashlog/` (app-specific upload logic); both are real, neither is dead code.
