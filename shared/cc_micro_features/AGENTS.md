# AGENTS.md — shared/cc_micro_features

Package-scoped addendum to the root `AGENTS.md` (read that first — this file only covers what's distinctive
about this package).

- **Project-blind (STRICT)**: features here must work in *any* app built on this template, not just this one.
  Never import from `lib/` (App Shell), `modules/data_config`, or `modules/domain_features`.
- Every feature defines its own `Repository` interface in `domain/` and implements it in its own `data/`
  (e.g. `auth`, `biometric`, `app_update`). Only app-specific config (e.g. `AppUpdateConfigRepository`) is
  implemented outside, in the App Shell — see root `AGENTS.md` rule 2.
- `domain/` and `data/` must be state-management agnostic (no Bloc/GetX). `presentation/` may use either.
- New feature → `lib/features/{name}/{data,domain,presentation}/`, then export from `lib/export_micro_features.dart`.
- DI: annotate classes in place (`@LazySingleton(as: ...)`); there is one shared `lib/core/di/di.dart` for the
  whole package — no per-feature DI file. See `feature_template.md` in this directory for full templates.
- Strings: never `CcLocaleKeys` (that is the app's `message` module). Add the key to
  `lib/l10n/cc_mf_locale_keys.dart` (path under `mf.`) and its value to every locale map in
  `lib/l10n/cc_mf_translations.dart`; the app merges `CcMfTranslations.mapLocales` into its loader.
- `crash_log/` here is the reusable crash-log **viewer UI** — not to be confused with
  `modules/domain_features/lib/features/crashlog/` (app-specific upload logic); both are real, neither is dead code.
- Dependencies: constructor injection only; `getIt` only at the composition root; split classes above 5
  dependencies — root `AGENTS.md` section IV, "Injecting dependencies".
