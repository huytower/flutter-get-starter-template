# Contributing Guide

This file describes how to contribute safely to the `flutter-get-starter-template` repository and keep
architecture docs aligned. The architecture rules themselves live in `/AGENTS.md` — this file is process
(what order to do things in, what to update, what to check) and doesn't restate those rules.

## What to do first

1. Read `../README.md` and `docs/onboarding.md`.
2. Read `/AGENTS.md` for the architecture rules and module boundaries (`docs/AI_CONTEXT.md` has the deeper
   rationale if you want the "why").
3. Identify where the change belongs — `/AGENTS.md`'s "Workspace layout" section maps each directory's purpose;
   each package also has its own package-scoped `AGENTS.md` for anything distinctive to it.

## How to add a new feature

Follow `shared/cc_micro_features/feature_template.md` for the file-by-file template (current, code-verified DI
pattern) and `/AGENTS.md` section IV for the DI convention. Then:

1. Export the feature from `cc_micro_features/lib/export_micro_features.dart` (reusable) or
   `modules/domain_features/lib/export_domain_features.dart` (app-specific).
2. Run `melos run gen` then `melos run analyze`.

## Documentation and sync

Whenever you move or rename major modules, update:

- `/AGENTS.md` and its package-scoped copies — this is the source of truth agents and contributors read first.
- `../README.md`
- `docs/AI_CONTEXT.md` (if the rationale changed, not just the rule)
- `docs/onboarding.md`
- package-level `README.md` files when they exist

Don't restate `/AGENTS.md` rules into other docs — link to it instead, so there's one place to keep correct.

## Pull request checklist

- [ ] Confirm the change is in the correct module/package (`/AGENTS.md` workspace layout + import-boundary rules).
- [ ] Confirm module DI is registered correctly (annotate in place, no per-feature DI file, `melos run gen` run).
- [ ] Confirm all heavy services use `@lazySingleton` to maintain < 2s startup.
- [ ] Confirm `melos run analyze` reports no errors.
- [ ] Confirm `/AGENTS.md` (and any package-scoped copy) is updated if module boundaries changed.
- [ ] Confirm feature exports are added if the change is reusable.
