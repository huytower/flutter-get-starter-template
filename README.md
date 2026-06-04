# Flutter Get Starter Template

A modular starter kit built around **Clean Architecture** and **SOLID** principles. Designed to help junior and new developers find the right entry points, understand module boundaries, and extend the app safely.

## 🎯 Critical Architecture Principle: State-Management Agnostic Design

**Core libraries (cc_sdk, cc_sdk_ui, cc_mixin, features) MUST be state-management agnostic.**

This project enforces a **state-management agnostic design** principle for all core libraries. This ensures that core components work with GetX or Bloc without being tied to a specific one.

### Why State-Management Agnostic Design Matters

- **Flexibility**: Teams can choose different state management approaches for different features
- **Reusability**: Components can be reused across projects with different state management preferences
- **Future-Proof**: Easy to migrate between state management libraries as needs change
- **Team Autonomy**: Different teams can work independently without state management conflicts
- **Testing**: Pure, stateless components are easier to test in isolation

### Key Guidelines

#### ✅ ALLOWED in Core Libraries (cc_sdk, cc_sdk_ui, cc_mixin, features):
- Pure data classes (models, entities)
- Utility functions and helpers
- Network utilities and interceptors
- Form validators (pure logic)
- Mixins with required/optional methods
- Interfaces and abstract classes
- Callback-based widgets

#### ❌ NOT ALLOWED in Core Libraries (cc_sdk, cc_sdk_ui, cc_mixin, features):
- GetX controllers and reactive variables
- Bloc cubits and blocs
- Provider state management
- Riverpod providers
- State management-specific widgets

#### ✅ ALLOWED in Presentation Layer (lib/presentation):
- GetX controllers and reactive variables
- Bloc cubits and blocs
- Provider state management
- Any state management approach of choice

**See `docs/AI_CONTEXT.md` for comprehensive guidelines, architecture details, and development rules.**

## Development Requirements

- **Flutter:** 3.41.9 or higher
- **Dart:** 3.11.5 or higher
- **Melos:** 7.8.0 (workspace version)
- **Code Generation:** Required for Hive adapters, JSON serialization, DI setup

## Quick start for new developers

1. Read `docs/AI_CONTEXT.md` for architecture overview and **state-management agnostic design principles**.
2. Ensure you have Flutter 3.41.9+ and Dart 3.11.5+ installed
3. Run `melos bootstrap` to set up the workspace
4. Run `melos run gen` to generate code for Hive adapters, JSON serialization, etc.
5. Open `lib/main.dart` to follow app startup and feature wiring.
6. Inspect `lib/core/di/di.dart` for global dependency registration.
7. Explore `modules/` for app-specific domain/data modules.
8. Explore `features/lib/export_features.dart` for reusable feature packages.
9. Read `docs/onboarding.md` for step-by-step developer onboarding.
10. Use `docs/CONTRIBUTING.md` for workflow, code review, and documentation sync rules.

## Development Workflow

```bash
# Bootstrap the workspace
melos bootstrap

# Generate code (after adding new models, adapters, or DI annotations)
melos run gen

# Run analysis
melos run analyze

# Run tests
melos run test

# Clean and rebuild
melos clean
melos bootstrap
melos run gen
```

## CI/CD Setup

This project uses **Melos 7.x.x** with pub workspaces for monorepo management. The CI/CD pipeline requires:

1. **Flutter 3.41.9+** with Dart 3.11.5+ for workspace compatibility
2. **Code generation** runs before analysis to ensure generated files are available
3. **Generated files** are committed for app_config and data modules (.g.dart files)
4. **Analysis rules** configured for generated file compatibility

### CI Configuration

- **Workspace:** Melos 7.x.x pub workspaces (no melos.yaml, uses pubspec.yaml workspace config)
- **Global Melos activation:** Required for script compatibility in CI
- **Generated files:** Selected modules commit generated files for analysis
- **Lint rules:** `prefer_relative_imports` disabled for generated files

## Project Structure

```
flutter-get-starter-template/
├── lib/                          # Main app code
│   ├── core/                     # Core app logic
│   ├── data/                     # Data layer
│   ├── presentation/             # UI layer
│   └── main*.dart               # Entry points
├── modules/                      # App-specific modules
│   ├── app_config/              # Configuration, DI, storage
│   ├── data/                    # Data sources, repositories
│   ├── message/                 # i18n/localization
│   └── theme/                   # Theming system
├── cc_core_sdk/                  # Reusable libraries
│   ├── cc_sdk/                  # Core SDK
│   ├── cc_sdk_ui/               # UI component library
│   ├── cc_mixin/                # Reusable mixins
│   └── features/                # Modular feature packages
└── docs/                        # Documentation
```

## Key Libraries & Modules

### Core Libraries

- **cc_sdk**: Core SDK functionality (network, device info, failures, utilities)
- **cc_sdk_ui**: Reusable UI components (buttons, forms, dialogs, navigation, theming)
- **cc_mixin**: Reusable mixins (navigation, validation, lifecycle patterns)
- **features**: Modular feature packages (auth, counter, etc.)

### App Modules

- **app_config**: Application configuration, DI, and storage
- **data**: Data layer configuration, repositories, data sources
- **theme**: Theming system
- **message**: Internationalization (i18n) and localization

## Libraries & Tools Used

- [melos](https://pub.dev/packages/melos) - Monorepo management with pub workspaces
- [getx](https://pub.dev/packages/get) - State management
- [bloc](https://pub.dev/packages/bloc) - State management
- [get_it](https://pub.dev/packages/get_it) - Service locator
- [injectable](https://pub.dev/packages/injectable) - DI code generation
- [retrofit](https://pub.dev/packages/retrofit) - HTTP client
- [build_runner](https://pub.dev/packages/build_runner) - Code generation
- [json_serializable](https://pub.dev/packages/json_serializable) - JSON serialization

## Documentation

- **AI_CONTEXT.md**: Architecture guidelines, development rules, and AI instructions
- **onboarding.md**: Step-by-step developer onboarding guide
- **CONTRIBUTING.md**: Workflow, code review, and documentation rules

## Architecture Principles

### Clean Architecture
- **Domain Layer**: Business logic, use cases, entities, repository interfaces
- **Data Layer**: Data sources (remote/local), repository implementations
- **Presentation Layer**: UI components, pages, widgets

### SOLID Principles
- **Single Responsibility**: Each class/module has one reason to change
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Subtypes must be substitutable for base types
- **Interface Segregation**: Clients shouldn't depend on unused interfaces
- **Dependency Inversion**: Depend on abstractions, not concretions
