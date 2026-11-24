# Onboarding Guide

This guide is for new developers joining the project and for anyone who needs a fast path into the repository.
For AI agents, or for the architecture rulebook itself, start at `/AGENTS.md` instead — this doc is the human
fast-path and doesn't restate those rules.

## What this project is

**Sổ Sách Xịn**, an offline-first personal finance app (product spec in `docs/BUSINESS_REQUIREMENT.md`, a local-only file that is git-ignored), built as a
modular Flutter workspace with:

- Clean Architecture
- SOLID principles
- Reusable packages for core logic, UI components, and feature modules
- GetIt + Injectable dependency injection

## Firebase Configuration

This project uses Firebase for Auth, Firestore (cloud sync), Cloud Messaging, Remote Config (forced update),
Firebase AI (Gemini), Analytics, Crashlytics, Performance Monitoring, and App Check. Due to security, the actual
configuration files are ignored by Git.

To set up Firebase for local development:

1. **Automatic Setup (Recommended):**
   Run the following command from the root directory:
   ```bash
   melos run setup:firebase
   ```
    This will copy the `.template` files to the required `.json` and `.plist` locations for the `prod` flavor.

2. **Manual Setup:**
   If you need to use your own Firebase project, manually create/update:
    - **Android:** `android/app/src/{flavor}/google-services.json`
    - **iOS:** `ios/Firebase/{flavor}/GoogleService-Info.plist`

## Most important files

1. `lib/main.dart`
    - App startup flow (target < 2 s), boot order in `AGENTS.md` rule 6:
      Env -> parallel Firebase / DI / Hive / i18n -> fire-and-forget services -> UI
    - Uncaught-error handling (`Catcher2` set up through `CcCatcherBootstrap`)

2. `lib/core/di/di.dart`
    - Global DI assembly
    - Includes module DI from `cc_micro_features`, `modules/data_config`, `modules/app_config`, etc.

3. `shared/cc_micro_features/lib/export_micro_features.dart`
    - Exports reusable feature packages
    - New reusable features should be added here

4. `modules/domain_features/lib/core/di/di.dart`
    - DI entry of the app's business features (one per package, `initMicroPackage()`)

5. `modules/data_config/lib/core/di/di.dart`
    - DI for app-wide data infrastructure (Dio/Retrofit setup, exchange rates)

6. `shared/cc_core_sdk/cc_sdk/lib/core/di/di.dart`
    - Core SDK DI (`shared/cc_core_sdk` is a git submodule — on first clone run
      `git submodule update --init --recursive`; afterwards keep it on `main`, see `AGENTS.md`)

7. `modules/domain_features/lib/features/firestore/financial_data_sync_service.dart`
    - Local-first sync: repositories call `syncAll()` after every local write; Profile tab can trigger it manually

8. `modules/bridge/` vs `cc_bridge/`
    - `cc_bridge` = project-blind contracts; `modules/bridge` = the App Shell's only gateway to features (shell contracts + every coordinator impl). Different jobs.

## Current feature pattern

Reusable features live under `shared/cc_micro_features/lib/features/`; app-specific ones under
`modules/domain_features/lib/features/`.

Each feature should generally follow this structure (there is no per-feature DI file: the package's single
`lib/core/di/di.dart` picks up the annotated classes):

```
{feature_name}/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── get_x/        # GetX controllers (or bloc/ for Bloc)
    ├── pages/
    └── widgets/
```

### Example: crash_log feature

The crash log viewer was moved into:

- `shared/cc_micro_features/lib/features/crash_log/crash_log_viewer_page.dart`
- `shared/cc_micro_features/lib/features/crash_log/crash_log_dev_overlay.dart`
- `shared/cc_micro_features/lib/features/crash_log/export_crash_log.dart`

Use the feature package import:

```dart
import 'package:cc_micro_features/features/crash_log/export_crash_log.dart';
```

## How to add a new reusable feature

Follow `shared/cc_micro_features/feature_template.md` for the full file-by-file walkthrough (it has the current,
code-verified DI pattern — annotate classes in place, there's no per-feature DI file). Study
`modules/domain_features/lib/features/wallet/` as the up-to-date reference structure; don't copy from
`modules/domain_features/lib/features/examples/`, which is tutorial scaffolding, not a real pattern.

## How to start working on a bug or task

1. Open the issue or ticket description.
2. Identify the related module/package.
    - Feature screens live in the feature's `presentation/` (`modules/domain_features` or `cc_micro_features`);
      `lib/presentation` holds only the shell (navigation bar / rail), and shared widgets live in
      `shared/cc_core_sdk/cc_sdk_ui`
    - Domain logic changes often live in `modules/domain_features` feature domain folders
    - Reusable feature changes often live in `cc_micro_features`
3. Find the DI entry points.
4. Confirm current behavior by running the app or using existing examples.
5. Make the change, then run `melos run check:imports` and `flutter analyze` (in the package you touched).

## Useful commands

Full list in `AGENTS.md` ("Commands").

- `melos bootstrap` - Bootstrap the workspace
- `melos run setup:firebase` - Initialize Firebase config from templates
- `melos run gen` - Generate code for all packages (`dart run build_runner build --delete-conflicting-outputs`)
- `melos run check:imports` - Import-boundary check (first CI step)
- `melos run analyze` / `melos run test` - Analyze / test every package
- In one package: `flutter analyze`, `flutter test`
- `flutter run -d <device> --flavor prod -t lib/main_prod.dart --dart-define-from-file=env/prod.json` - run the
  app (only the `prod` flavor exists; copy `env/prod.example.json` to `env/prod.json` first)

## Recommended workflow

- Use package exports for cross-package imports
- Keep module boundaries clean: domain should not depend on presentation
- Prefer abstractions (interfaces, repositories) in DI
- Document new feature package exports in `shared/cc_micro_features/lib/export_micro_features.dart`
- Keep `README.md` and `docs/AI_CONTEXT.md` in sync with major structure changes
