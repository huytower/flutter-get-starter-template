# Contributing Guide

This file describes how to contribute safely to the `flutter-get-starter-template` repository and keep
architecture docs aligned. The architecture rules themselves live in `/AGENTS.md` — this file is process
(what order to do things in, what to update, what to check) and doesn't restate those rules.

## What to do first

Paths below are relative to the repository root.

1. Read `README.md` and `docs/onboarding.md`.
2. Read `AGENTS.md` for the architecture rules and module boundaries (`docs/AI_CONTEXT.md` has the deeper
   rationale if you want the "why").
3. Identify where the change belongs — `AGENTS.md`'s "Workspace layout" section maps each directory's purpose;
   most packages also have a package-scoped `AGENTS.md` for anything distinctive to them.

## How to add a new feature

Follow `shared/cc_micro_features/feature_template.md` for the file-by-file template (current, code-verified DI
pattern) and `AGENTS.md` section IV for the DI convention. Then:

1. Export the feature from `shared/cc_micro_features/lib/export_micro_features.dart` (reusable) or
   `modules/domain_features/lib/export_domain_features.dart` (app-specific).
2. Run `melos run gen`, `melos run check:imports`, then `melos run analyze`.

## Documentation and sync

Whenever you move or rename major modules, update:

- `AGENTS.md` and the package-scoped `AGENTS.md` files — the source of truth agents and contributors read first.
- `README.md`
- `docs/AI_CONTEXT.md` (if the rationale changed, not just the rule)
- `docs/onboarding.md`
- package-level `README.md` files when they exist
- `CHANGELOG.md` (under `## Unreleased`) for any user-visible or structural change

Don't restate `AGENTS.md` rules into other docs — link to it instead, so there's one place to keep correct.

## Pull request checklist

The full delivery checklist is `AGENTS.md` rule 21; this is the PR-level summary.

- [ ] Confirm the change is in the correct module/package (`AGENTS.md` workspace layout + import-boundary rules).
- [ ] Confirm module DI is registered correctly (annotate in place, no per-feature DI file, `melos run gen` run).
- [ ] Confirm all heavy services use `@lazySingleton` to maintain < 2s startup.
- [ ] Confirm `melos run check:imports`, `melos run analyze` and `melos run test` pass.
- [ ] Confirm `AGENTS.md` (and any package-scoped copy) is updated if module boundaries changed.
- [ ] Confirm feature exports are added if the change is reusable.
- [ ] Confirm `CHANGELOG.md` has an entry under `## Unreleased`.
