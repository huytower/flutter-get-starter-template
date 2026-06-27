# Onboarding Guide

This guide is for new developers joining the project and for anyone who needs a fast path into the repository.

## What this project is

A modular Flutter starter template built with:

- Clean Architecture
- SOLID principles
- Reusable packages for core logic, UI components, and feature modules
- GetIt + Injectable dependency injection

## Firebase Configuration

This project uses Firebase for Crashlytics, Performance Monitoring, and App Check. Due to security, the actual
configuration files are ignored by Git.

To set up Firebase for local development:

1. **Automatic Setup (Recommended):**
   Run the following command from the root directory:
   ```bash
   melos run setup:firebase
   ```
   This will copy the `.template` files to the required `.json` and `.plist` locations for all flavors (`free`, `prod`,
   `uat`).

2. **Manual Setup:**
   If you need to use your own Firebase project, manually create/update:
    - **Android:** `android:app/src/{flavor}/google-services.json`
    - **iOS:** `ios/Firebase/{flavor}/GoogleService-Info.plist`

## Most important files

1. `lib/main.dart`
    - App startup flow (Turbo Parallel Boot < 2s)
    - Critical initialization sequence (Env -> Parallel DI/Hive/I18n)
    - Crash log feature wrapper

2. `lib/core/di/inject/inject.dart`
    - Global DI assembly
    - Includes module DI from `cc_micro_features`, `modules/data`, `modules/app_config`, etc.

3. `cc_micro_features/lib/export_micro_features.dart`
    - Exports reusable feature packages
    - New reusable features should be added here

4. `modules/data/lib/core/di/di.dart`
    - Data module DI registration
    - Remote/local repository wiring

5. `modules/theme/lib/core/di/di.dart`
    - Theme module DI registration and exports

6. `cc_core_sdk/cc_sdk/lib/core/di/di.dart`
    - Core SDK DI exports

## Current feature pattern

Reusable feature packages live under `cc_micro_features/lib/features/`.

Each feature should generally follow this structure:

```
{feature_name}/
├── core/di/di.dart
├── data/
│   ├── datasources/
│   ├── repositories/
│   └── model/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── pages/
    └── widgets/
```

### Example: crash_log feature

The crash log viewer was moved into:

- `cc_micro_features/lib/features/crash_log/crash_log_viewer_page.dart`
- `cc_micro_features/lib/features/crash_log/crash_log_dev_overlay.dart`
- `cc_micro_features/lib/features/crash_log/export_crash_log.dart`

Use the feature package import:

```dart
import 'package:cc_micro_features/features/crash_log/export_crash_log.dart';
```

## How to add a new reusable feature

1. Create a new feature folder under `cc_micro_features/lib/features/`.
2. Add `core/di/di.dart` for feature DI registration. **CRITICAL**: Use `@lazySingleton` for all heavy services to maintain < 2s startup.
3. Add domain contracts and use cases under `domain/`.
4. Add data sources and repository implementations under `data/`.
5. Add UI pages/widgets under `presentation/`.
6. Export the feature from `cc_micro_features/lib/export_micro_features.dart`.
7. Update the main app imports to use the feature package export.
8. Run `flutter pub get` and `flutter analyze`.

## How to start working on a bug or task

1. Open the issue or ticket description.
2. Identify the related module/package.
    - UI/UX changes often live in `lib/presentation` or `cc_core_sdk/cc_sdk_ui`
    - Domain logic changes often live in `modules/data` or feature domain folders
    - Reusable feature changes often live in `cc_micro_features`
3. Find the DI entry points.
4. Confirm current behavior by running the app or using existing examples.
5. Make the change, then run `flutter analyze`.

## Useful commands

- `melos bootstrap` - Bootstrap the workspace
- `melos run gen` - Generate code for all modules
- `melos run setup:firebase` - Initialize Firebase config from templates
- `flutter pub get`
- `flutter analyze`
- `flutter pub run build_runner build --delete-conflicting-outputs`
- `flutter test`

## Recommended workflow

- Use package exports for cross-package imports
- Keep module boundaries clean: domain should not depend on presentation
- Prefer abstractions (interfaces, repositories) in DI
- Document new feature package exports in `cc_micro_features/lib/export_micro_features.dart`
- Keep `README.md` and `docs/AI_CONTEXT.md` in sync with major structure changes
