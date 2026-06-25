# Micro-Features Library

A collection of **project-blind, reusable Micro-Features** following the Hybrid-Modular Super App architecture. These are standalone business verticals (Feature-as-a-Service) designed to be shared across multiple enterprise applications.

## 🎯 The "Global Lego" Principle

Micro-Features are engineered as independent blocks. They follow two strict rules:
1.  **Project-Blind**: They must NEVER depend on the App Shell (`lib/`) or app-specific data modules. They only communicate via interfaces (Dependency Inversion).
2.  **State-Management Agnostic Core**: While they may use Bloc or GetX in their `presentation/` layer, their business logic (domain/data) is strictly decoupled and agnostic.

## 📁 Directory Structure

```
lib/
├── core/                  # Shared logic within micro_features
│   ├── di/               # Local Micro-Package DI registration
│   └── navigation/       # Feature-specific routing (AutoRoute)
│
├── {feature_name}/        # Micro-Feature module (snake_case)
│   ├── data/
│   │   ├── datasources/  # Remote/Local data fetchers
│   │   ├── models/       # JSON DTOs (Data Transfer Objects)
│   │   └── repositories/ # Repository implementations
│   │
│   ├── domain/
│   │   ├── entities/     # Project-agnostic business objects
│   │   ├── repositories/ # Abstract repository contracts
│   │   └── usecases/     # Pure business logic (suffix: _usecase.dart)
│   │
│   ├── presentation/
│   │   ├── bloc/        # State management (Bloc/Cubit/GetX)
│   │   ├── pages/       # Feature screens (suffix: _page.dart)
│   │   └── widgets/     # Feature-specific sub-widgets
│   │
│   └── export_{name}.dart  # Single public API export for the feature
│
└── export_micro_features.dart  # Root export for all micro-features
```

## 🏗️ Dependency Inversion (Interface-Driven)

If a Micro-Feature needs to access project-specific data (e.g., an app-specific Auth implementation), it MUST NOT import it. Instead:
1.  Define an `abstract class` (Interface) in the Micro-Feature's `domain/repositories/`.
2.  The App Shell (`lib/`) or local `modules/data` implements this interface.
3.  Inject the implementation via DI during the App Shell's startup.

## 🚀 Development Workflow

### Adding a New Micro-Feature
1.  Create a folder under `lib/features/`.
2.  Follow the **Suffix-First** naming convention (e.g., `login_usecase.dart`).
3.  Implement the three CLEAN layers.
4.  Export the feature via `export_{name}.dart` and register it in `export_micro_features.dart`.
5.  Run code generation:
    ```bash
    melos run gen
    ```

## 📦 Core Dependencies
- `cc_core_sdk`: The engine for logic and UI.
- `injectable` & `get_it`: For modular dependency management.
- `auto_route`: For cross-feature navigation.
- `multiple_result`: For functional error handling.

## 🔗 Related SDKs
- [cc_sdk_ui](../cc_core_sdk/cc_sdk_ui/README.md): Design System.
- [cc_sdk](../cc_core_sdk/cc_sdk/README.md): Core Utilities.
