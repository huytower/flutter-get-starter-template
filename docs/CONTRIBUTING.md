# Contributing Guide

This file describes how to contribute safely to the `flutter-get-starter-template` repository and keep architecture docs
aligned.

## What to do first

1. Read `../README.md` and `docs/onboarding.md`.
2. Check `docs/AI_CONTEXT.md` for architecture intent and module boundaries.
3. Identify where the change belongs:
    - UI or shared widgets: `cc_core_sdk/cc_sdk_ui`
    - Reusable micro-features: `cc_micro_features/lib/features/`
    - App-specific data and domain: `modules/data`
    - App configuration: `modules/app_config`
    - Theming: `modules/theme`

## How to add a new feature

1. Create a new feature folder under `cc_micro_features/lib/features/` (for reusable micro-features) or `modules/domain_features/lib/features/` (for app-specific features).
2. Follow the pattern:
    - `core/di/di.dart` (use `@lazySingleton` for heavy services to maintain Turbo Boot < 2s)
    - `data/` for datasources/repositories
    - `domain/` for entities/repositories/usecases
    - `presentation/` for pages/widgets
3. Export the feature from `cc_micro_features/lib/export_micro_features.dart` (reusable) or `modules/domain_features/lib/export_features.dart` (app-specific).
4. Update the app import paths to use the feature package export.
5. Run:
    - `flutter pub get`
    - `flutter analyze`
    - `flutter pub run build_runner build --delete-conflicting-outputs`

## Dependency injection rules

- Use `getIt` as the shared service locator.
- Each module should expose a `lib/core/di/di.dart` entry.
- Use `@InjectableInit.microPackage()` in module DI entry files.
- Avoid concrete imports across layers; depend on abstractions.

## Documentation and sync

Whenever you move or rename major modules, update:

- `../README.md`
- `../AI_CONTEXT.md`
- `docs/onboarding.md`
- package-level `README.md` files when they exist

## Code style and commands

- Keep classes single-responsibility.
- Keep feature module exports explicit.
- Keep domain logic separate from presentation.

## Pull request checklist

- [ ] Confirm the change is in the correct module/package.
- [ ] Confirm module DI is registered correctly.
- [ ] Confirm all heavy services use `@lazySingleton` to maintain < 2s startup.
- [ ] Confirm `flutter analyze` reports no errors.
- [ ] Confirm documentation is updated for new module boundaries.
- [ ] Confirm feature exports are added if the change is reusable.
