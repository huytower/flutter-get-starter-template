# AI Context - Flutter Get Starter Template

A modular Flutter starter built around **Clean Architecture** and **SOLID principles**, with reusable packages for core
SDK, UI, and feature modules.

**Project Path:** `C:\Users\Admin\repository\flutter-get-starter-template`

## AI Guidelines & Strategic Guardrails

### I. ARCHITECTURAL INTEGRITY (The Laws)

1. **Hybrid-Modular Super App Design (CRITICAL)**: The project is divided into three distinct layers:
    - **App Shell (Host)**: The `lib/` folder. Acts as a **Pure Orchestrator**. It contains ONLY glue code (Routing,
      Global DI, Coordinator Impl). It MUST NOT contain vertical business logic or feature-specific UI.
    - **Domain Features (Verticals)**: The `modules/domain_features/` folder. Contains business-specific verticals (
      Home, Comment, Wallet, etc.). These follow Clean Architecture and own their own Domain logic.
    - **Micro-Features (Global Legos)**: The `shared/cc_micro_features/` folder. Project-blind business verticals (
      Auth, Biometric, etc.) reusable across different enterprise apps.
    - **Shared Core (Engine)**: The `shared/cc_core_sdk/` folder (git submodule → `huytower/cc_core_sdk`). Universal
      logic (Network, Auth logic, Design System). NOTE: it lives under `shared/`, not at the repo root.
    - **Bridge Layer**: The `cc_bridge/` folder (root level). Communication contracts and interfaces for cross-module
      interaction.

2. **Project-Blind Dependency Rules (STRICT)**:
    - Components in `cc_micro_features/` and `domain_features/` **MUST NOT** import from `lib/` (App Shell).
    - `cc_micro_features/` MUST NOT import from `domain_features/` or `modules/data_config`.
    - **Dependency Inversion**: Features define their own `Repository` interfaces in their `domain/` layer. The App
      Shell or local `modules/data_config` implements these interfaces and injects them via DI.
    - This ensures features can be moved or replaced without code changes in other modules.

3. **State-Management Agnostic Core (STRICT)**:
    - `cc_core_sdk` modules (`cc_sdk`, `cc_sdk_ui`, `cc_mixin`, `cc_bridge`) MUST NOT depend on a specific **state
      management** solution (Bloc/GetX/Provider) for holding or reacting to app state.
    - **Pragmatic exception**: `cc_sdk_ui` (and transitively `cc_sdk`) depends on the `get` package for *lightweight
      context/navigation helpers only* (e.g. `Get.context!`, `Get.dialog`, `Get.back()` in `CcDialogHelper`). This is
      NOT state management — no `GetxController`/`Obx` is used. Do not introduce reactive GetX state into the core.
    - Features may use state management (Bloc/GetX) in their `presentation/` layer, but their `domain/` and `data/`
      layers must remain agnostic (no Bloc events, no `Obx`, no `GetxController` in `domain/`/`data/`).

4. **Interface-Driven Communication (The Bridge)**:
    - All cross-module interactions (e.g., Navigation, Session Management) must be mediated by contracts defined in
      `cc_bridge`.
    - **Contract Naming**: Use `*Coordinator` for flow (Navigation), `*Contract` for shared state (Session), and
      `*Provider` for shared logic.
    - Features should depend on abstractions, never on concrete implementations of other features.

23. **Layer Purity Within a Feature (STRICT)**:
    - `domain/` and `data/` layers MUST NOT import from their own (or any other) `presentation/` layer. Presentation
      types (Bloc `Event`/`State`, `Obx`, `GetxController`, UI widgets) never flow into `domain/`/`data/`.
    - Streams/data crossing the `domain`↔`presentation` boundary must use domain types (e.g. a sealed
      `*Status`/`*Entity`), not presentation event classes. (The `auth` feature uses `PhoneAuthStatus` for this.)

5. **Clean Bootstrap Integrity (CRITICAL PERF)**:
    - Preserve `main.dart` as a lean, service-only entry point.
    - **Startup Target**: < 2 seconds.
    - **Boot Sequence (STRICT)**:
        1. `await initEnv()` (Must be first for DI/Flags).
        2. `await Future.wait([...])` (Parallelize Firebase, DI, Hive, Localization).
        3. `CcAppCheckHelper.initialize()` (Non-blocking background).
    - **Lazy Initialization**: All heavy infrastructure (Network, Routing, Repos) MUST be `@lazySingleton` to prevent "Constructor Leaks" during parallel boot.
    - **Deferred Telemetry**: Non-essential services (Logging, Performance) must be deferred to the `NavigationBar` shell via `NavigationLogicMixin`.

### II. DESIGN SYSTEM & UI (The Look)

6. **Color & Typography (Single Source of Truth)**:
    - **Colors**: Flow from `CcBaseColors` (Primitives) → `PrjColors` (Semantic Roles) → `context.ccColorScheme` (
      Widgets). NEVER hardcode hex colors or use `Colors.*` directly.
    - **Typography**: Standardized on **Plus Jakarta Sans**. Access via `context.ccTextTheme`. NEVER hardcode font sizes,
      weights, or families in widgets.
    - **Chain of Truth**: `CcTypographyParams` (tokens) → `CcTextStyle` (semantic) → `context.ccTextTheme` (widgets).

7. **Multi-Screen & Orientation Support (Adaptive-First)**:
    - Use `context.respPadding()`, `context.respFontSize()`, and `context.respDim()` for all dimensions.
    - Use `CcResponsiveContainer` and `CcResponsiveFlex` for adaptive layouts.
    - **Breakpoints**: Small Mobile (<360px), Mobile (360-600px), Tablet (600-900px), Desktop (>900px).
    - **Mandatory**: All UI must be verified for both portrait and landscape orientations.

8. **Localization & Messaging**:
    - Use `el.tr(CcLocaleKeys.key)` for ALL user-facing strings. No hardcoded strings.
    - Reference keys from the `message` module.
    - **Proactive Localization (3-file contract)**: When adding new strings, you MUST keep three artifacts in sync:
        1. `modules/message/assets/translations/en.json`
        2. `modules/message/assets/translations/vi.json`
        3. `modules/message/lib/cc_locale_keys.dart` (the key constant **and** its `CodegenLoader` map entries).
           This works immediately without an `easy_localization:generate` build step, but the triplet is easy to desync.
    - **CI Guard (recommended)**: Add a CI step that fails the build if `en.json`/`vi.json` keys diverge or if any
      `CcLocaleKeys` constant is missing from the JSON files. Until that exists, treat desync as a build-blocking bug.

9. **SDK-First Component Reuse**: Prioritize using and extending components from `cc_core_sdk/cc_sdk_ui` before building
   custom widgets.

### III. CODE QUALITY & STANDARDS (The Feel)

10. **Suffix-First Naming Convention**:
    - To avoid name collisions in a Super App, use mandatory suffixes:
        - Entities: `*_entity.dart` | UseCases: `*_usecase.dart`
        - Repositories: `*_repository.dart` | Repositories (Impl): `*_repository_impl.dart`
        - Models/DTOs: `*_model.dart` | Pages: `*_page.dart`
        - Bloc/Cubit: `*_bloc.dart` / `*_cubit.dart` | State/Event: `*_state.dart` / `*_event.dart`
    - Use `lower_snake_case` for all files.

11. **Import Hygiene (CRITICAL)**:
    - Always prefer centralized exports (e.g., `import 'package:cc_micro_features/export_micro_features.dart'`).
    - NEVER duplicate imports (e.g., do not import a centralized export AND a specific file from that same module).
    - **Order**: 1. Flutter/Dart, 2. External packages, 3. Project modules, 4. Local relative imports.

12. **Standardized Functional Results**:
    - All UseCases and Repositories must return `Result<T, CcFailure>` from the `multiple_result` package to ensure
      consistent error handling. (`CcFailure` is the project's failure type, defined in `cc_sdk`.)

13. **Logging Strategy**:
    - Use the `.Log()` extension from `cc_sdk` for all debug logging.
    - Handles environment-based silencing (via `CcFeatureFlags`), automatic serialization (via `ccGson`), and context
      capture.
    - NEVER use `print()` or `developer.log()` in production code.

14. **Git Management & Code Organization**:
    - Keep files focused (max 200-300 lines). Use Widget Composition to split large UIs.
    - Mark all possible constructors and widgets as `const`.
    - Extract constants to dedicated files when needed.
    - **Extract many small methods from `build()`** (e.g. `_buildHeader`, `_buildListItem`, `_buildActions`). Small,
      single-purpose methods localize changes to distinct regions, drastically reducing merge conflicts when multiple
      developers edit the same screen. Prefer several focused methods over one large `build()` body.

15. **Spacing Tokens — Use `CcSpace*` Instead of Raw `SizedBox` (STRICT)**: For layout gaps, never use raw
    `SizedBox(height/width: context.respDim(N))`; always use the semantic `CcSpace*` spacers from `cc_sdk_ui`
    (`XS=4`, `SM=8`, `MD=12`, `LG=16`, `XL=24`). Only exact token values have a `CcSpace` equivalent — keep raw
    `SizedBox` for non-token gaps (e.g. 2/6pt) and for sizing shapes/icons/charts.

### IV. AI INTERACTION PROTOCOL (The Workflow)

16. **Evidence-Based Implementation**: Always use `read_file` and `analyze_file` to verify current structure and linter
    compliance before and after changes.

17. **Final-State Delivery**: Provide final, production-ready implementation immediately. Skip intermediate placeholders
    or "TODOs".

18. **Collaborative Evolution**: For structural changes (file movements, return type updates, DI shifts), present a
    clear plan and proceed after developer confirmation.

19. **Verification Protocol**: Before delivery, verify:
    - [ ] No Hardcoded Strings/Colors/Typography.
    - [ ] Functional responsiveness (`context.resp*`).
    - [ ] Import hygiene and Suffix-first naming.
    - [ ] Spacing uses `CcSpace*` components (not raw `SizedBox(respDim(N))` gaps).
    - [ ] Proactive Localization (JSONs + `CcLocaleKeys` + `CodegenLoader` updated and in sync).
    - [ ] Linter compliance (zero errors/warnings).

### V. ENFORCEMENT (Make the Laws Machine-Checkable)

Several guardrails above are currently only enforced by human review. Prefer automated checks so violations (like the
historical `auth` domain→presentation leak) are caught in CI, not in code review:

20. **Forbidden Import Boundaries (rules #2, #3, #23)**: Enforce via a lightweight CI script that greps for illegal
    imports, e.g.:
    - `shared/cc_micro_features/**/domain/**` and `**/data/**` MUST NOT import `*/presentation/**`, `lib/`,
      `modules/data_config`, or `domain_features` (rules #2, #23).
    - `cc_core_sdk/**` and `cc_bridge/**` MUST NOT import `bloc`, `flutter_bloc`, or reactive `get` (rule #3) — except
      the documented `get`-context exception in `cc_sdk_ui`.
      Add this as a `melos` script (`melos run check:imports`) and a CI gate.

21. **Import Order (rule #11)**: Keep `dart analyze` with `directives_ordering` enabled and rely on
    `dart fix --apply` in CI to auto-sort imports; do not disable it.

22. **Pre-Delivery Checklist (rule #19)**: Wire the checklist into CI as discrete gates (lint, localization-sync check,
    import-boundary check) so a red build == an unmet item, rather than a manual pre-flight.

## Project Structure

```
flutter-get-starter-template/
├── lib/                          # App Shell (Pure Orchestrator)
│   ├── core/                     # Core app logic (Global DI, Root Routing)
│   ├── data/                     # Project-specific data (Impl, Adapters)
│   ├── presentation/             # Shell UI (NavigationBar, Root Scaffold)
│   └── main*.dart               # Entry points
├── modules/domain_features/      # Business Verticals (Vertical Features)
│   └── lib/features/            # Home, Comment, Wallet, Transaction, etc.
├── shared/cc_micro_features/     # Global Legos (Micro-Features)
│   └── lib/features/            # Auth, Biometric, Splash, etc.
├── shared/cc_core_sdk/           # Shared Core (Engine) — GIT SUBMODULE
│   ├── cc_sdk/                  # Core SDK (network, device, failures, ccGson)
│   ├── cc_sdk_ui/               # UI component library (CcContextExtension)
│   ├── cc_mixin/                # Reusable mixins
│   └── cc_sdk_data/             # Core data entities/models
├── cc_bridge/                   # Bridge for communication (root level)
├── modules/                      # App-specific modules
│   ├── app_config/              # Configuration, Storage
│   ├── message/                 # i18n/localization (CcLocaleKeys)
│   └── theme/                   # Theming system (PrjColors, CcTextStyle)
└── docs/                        # Documentation
```

## Dependency Injection (DI) Convention

| Category           | Convention                   | Example                         |
|:-------------------|:-----------------------------|:--------------------------------|
| **File Location**  | Always `lib/core/di/di.dart` | `data/lib/core/di/di.dart`      |
| **Method Name**    | Always `initMicroPackage()`  | `void initMicroPackage() {}`    |
| **Locator Name**   | Always `getIt`               | `final getIt = GetIt.instance;` |
| **Generated File** | Always `di.module.dart`      | `import 'di.module.dart';`      |

### Module Implementation

Every library and module must implement DI using Micro-Package pattern with `@InjectableInit.microPackage()` annotation
on `initMicroPackage()` method.

### Main App Integration

The main app consolidates all modules in `lib/core/di/di.dart` using `@InjectableInit` with
`externalPackageModulesBefore`.

## Core Libraries

### cc_core_sdk/cc_sdk (Core SDK)

**Source of Truth:** `cc_core_sdk/cc_sdk/README.md` (Refer to this for technical features and usage examples)

**Strategic Guardrails:**

- **State-Management Agnostic:** Must NOT depend on GetX, Bloc, or any specific state management library.
- **Clean Architecture:** Strictly follow Domain (UseCases/Failures), Data (Repositories/DataSources), and Core layers.
- **Logging:** All logs must use the standardized `.Log()` extension provided here.
- **Serialization:** Use the GSON-style serialization (`ccGson`) provided in this package.

**DI File:** `cc_core_sdk/cc_sdk/lib/core/di/di.dart`

### cc_core_sdk/cc_sdk_ui (UI Components)

**Source of Truth:** `cc_core_sdk/cc_sdk_ui/README.md` (Refer to this for widget catalog and design tokens)

**Strategic Guardrails:**

- **State-Management Agnostic:** All widgets must be stateless or manage state via standard callbacks/ValueNotifiers. No
  GetX/Bloc allowed.
- **Theme Sync:** Inherits typography (Plus Jakarta Sans) and colors via `CcContextExtension`.
- **Responsive-First:** All widgets must use `context.resp*` helpers for dimensions.

**DI File:** No DI file (stateless UI library)

### cc_core_sdk/cc_mixin (Reusable Mixins)

**Purpose:** Reusable mixins for common functionality (e.g., navigation, pagination).

**Strategic Guardrails:**

- **State-Management Agnostic:** Mixins must provide reusable functionality (via required methods/getters) without
  imposing GetX or Bloc.
- **Generic Logic:** Focus on boilerplate reduction (Scaffold config, Infinite scroll, Back button handling).

**DI File:** No DI file (mixin library)

### cc_bridge (Bridge Layer)

**Source of Truth:** `cc_bridge/README.md` (Refer to this for communication contracts and usage)

**Purpose:** Communication contracts and interfaces for cross-module interaction.

**Strategic Guardrails:**

- **Interface-Driven:** All cross-module communication must use contracts defined here.
- **State-Management Agnostic:** Contracts must not depend on specific state management.
- **Project-Blind:** Can be used across different enterprise applications.

**DI File:** `cc_bridge/lib/core/di/di.dart`

### cc_micro_features/ (Feature Modules)

**Source of Truth:** `shared/cc_micro_features/README.md` (Refer to this for feature list and implementation flow)

**Strategic Guardrails:**

- **Project-Blind (STRICT):** MUST NOT import from `lib/` or `modules/data_config`. Use Dependency Inversion (Interfaces).
- **Architecture:** Must follow the 3-layer Clean Architecture (Data, Domain, Presentation).
- **Agnostic Core:** Domain and Data layers MUST be state-management agnostic. Presentation layer can use Bloc or GetX.

**DI File:** `cc_micro_features/lib/core/di/di.dart`

## modules/domain_features/ (Vertical Features)

**Purpose:** Business-specific vertical features.
**Architecture:** 3-layer Clean Architecture.
**Logic:** Domain and Data must be state-management agnostic.
**DI File:** `modules/domain_features/lib/core/di/di.dart`

## App Modules

### modules/app_config

**Source of Truth:** `modules/app_config/README.md`
**Purpose:** Application configuration, Environment management, and DI discovery.
**DI File:** `modules/app_config/lib/core/di/di.dart`

### modules/data_config

**Source of Truth:** `modules/data_config/README.md`
**Purpose:** App-specific data implementations and repository orchestration.
**DI File:** `modules/data_config/lib/core/di/di.dart`

### modules/theme

**Source of Truth:** `modules/theme/README.md`
**Purpose:** Theming system (SSOT for Colors/Typography).
**Key Files:** `PrjColors`, `CcTextStyle`, `CcThemes`.

### modules/message

**Source of Truth:** `modules/message/README.md`
**Purpose:** i18n and localization (SSOT for Strings).
**Key Files:** `CcLocaleKeys`.

## Key Technologies

### Dependency Injection

- **get_it**: Service locator
- **injectable**: Code generation for DI (v3.0+)
- **Micro-Packages**: For modular DI discovery
- **Annotations**: @injectable, @module, @preResolve, @named, @singleton, @lazySingleton, @InjectableInit.microPackage()

### State Management

- **Multi-Support**: The project supports GetX and Bloc state management approaches
- **State-Management Agnostic Core**: Core libraries (cc_sdk, cc_sdk_ui, cc_mixin, cc_micro_features) must be
  state-management agnostic
- **Flexibility**: Choose the state management approach that works best for your feature or team
- **No Lock-in**: Core components are not locked to any specific state management library

**State-Management Usage:**

- Use GetX or Bloc in the `lib/presentation` layer for specific features
- Keep core libraries (cc_sdk, cc_sdk_ui, cc_mixin, cc_micro_features) state-management agnostic
- Provide abstract interfaces in features that can be implemented with GetX or Bloc
- Use dependency injection to inject state management implementations

## Multi-Screen & Orientation Support

### Screen Size Breakpoints

The app supports multiple screen sizes with the following breakpoints:

- **Small Mobile**: < 360px (foldable covers, small phones)
- **Mobile**: 360px - 600px (standard phones)
- **Tablet**: 600px - 900px (tablets)
- **Desktop**: > 900px (desktop screens)

### Orientation Handling

The app supports both portrait and landscape orientations. Before implementing UI components:

**Check Orientation Conditions:**

```dart
// Check current orientation
if (context.isPortrait) {
  // Portrait-specific layout
} else if (context.isLandscape) {
  // Landscape-specific layout
}
```

**Orientation-Specific Guidelines:**

- **Portrait Mode**: Default layout for most screens, optimized for single-handed use
- **Landscape Mode**: Consider for data-heavy screens (dashboards, tables, charts)
- **Auto-Rotation**: Allow rotation on tablets and desktop devices, restrict on phones if needed
- **Layout Adaptation**: Use `LayoutBuilder` or `OrientationBuilder` for orientation-specific widgets
- **Safe Areas**: Always account for safe areas and notches in both orientations

**Platform Configuration:**

- **Android**: `android:screenOrientation="unspecified"` in AndroidManifest.xml
- **iOS iPhone**: Portrait, LandscapeLeft, LandscapeRight in Info.plist
- **iOS iPad**: All orientations supported (Portrait, PortraitUpsideDown, LandscapeLeft, LandscapeRight)

### Responsive Design Implementation

Use the following utilities from `cc_sdk` and `cc_sdk_ui`:

**From cc_sdk:**

- `CcResponsiveHelper`: Screen type detection, responsive values, orientation helpers
- `CcDeviceHelper`: Screen dimensions, platform detection, keyboard height, orientation control (`setLandscape`,
  `setPortrait`)

**From cc_sdk_ui:**

- `CcResponsiveContainer`: Adaptive container with responsive padding/margin/width
- `CcResponsiveFlex`: Adaptive flex layout that adjusts columns based on screen size

**Implementation Checklist:**

- [ ] Test on small mobile (< 360px)
- [ ] Test on mobile (360px - 600px)
- [ ] Test on tablet (600px - 900px)
- [ ] Test on desktop (> 900px)
- [ ] Test in portrait orientation
- [ ] Test in landscape orientation
- [ ] Verify touch targets are appropriate for all screen sizes
- [ ] Ensure text is readable on all screen sizes
- [ ] Check layout doesn't overflow on small screens

## CI/CD Configuration

### Melos Workspace

- **Workspace:** Melos 7.8.1. The workspace packages are declared via `melos.yaml` `packages:`, and the workspace
  membership via `pubspec.yaml` `workspace:` entries.
- **Single Source of Truth for scripts:** ALL workspace scripts (`bootstrap`, `gen`, `rebuild`, `analyze`, `test`,
  `setup:firebase`, `check:imports`) are defined **only** in the root `pubspec.yaml` `melos.scripts` block. melos 7.8.1
  reads scripts from `pubspec.yaml`, NOT from `melos.yaml`. Do NOT duplicate them in `melos.yaml` — duplicated,
  divergent definitions cause drift (e.g. differing `rebuild`/`gen` commands). Keep `melos.yaml` free of a `scripts:`
  section.
- **Global Melos activation:** Required for script compatibility in CI (`melos bootstrap` / `melos run gen`).
- **Generated files:** Selected modules commit generated files for analysis.
- **Lint rules:** `prefer_relative_imports` disabled for generated files.

## Development Workflow

```bash
melos bootstrap              # Bootstrap the workspace
melos run gen                # Generate code
melos run analyze            # Run analysis
melos run test               # Run tests
melos clean                  # Clean and rebuild
```

## Architecture Principles

### Clean Architecture

- **Domain Layer**: Business logic, use cases, entities, repository interfaces
- **Data Layer**: Data sources (remote/local), repository implementations, entities
- **Presentation Layer**: UI components, pages, widgets

### SOLID Principles

- **Single Responsibility**: Each class/module has one reason to change
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Subtypes must be substitutable for base types
- **Interface Segregation**: Clients shouldn't depend on unused interfaces
- **Dependency Inversion**: Depend on abstractions, not concretions