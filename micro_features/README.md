# Features Library

A collection of reusable, modular feature packages following CLEAN architecture and SOLID principles.

## 📁 Directory Structure

```
lib/
├── core/                  # Shared code across features
│   ├── constants/        # App-wide constants
│   ├── di/               # Dependency injection setup (Injectable)
│   └── utils/            # Shared utilities
│
├── {feature_name}/        # Feature modules (lowercase with underscores)
│   ├── data/
│   │   ├── datasources/  # Data sources (API, local storage, etc.)
│   │   └── repositories/ # Repository implementations
│   │
│   ├── domain/
│   │   ├── entities/     # Business objects
│   │   ├── repositories/ # Repository contracts
│   │   └── usecases/    # Business logic
│   │
│   ├── presentation/
│   │   ├── bloc/        # State management (Bloc/Cubit)
│   │   ├── pages/       # Feature screens
│   │   └── widgets/     # Reusable UI components
│   │
│   ├── {feature_name}_init.dart    # Initialization logic
│   └── {feature_name}_export.dart  # Public API exports
│
└── export_features.dart          # Root export for all features
```

## 🚀 Getting Started

### Adding to Your Project

Add this to your app's `pubspec.yaml`:

```yaml
dependencies:
  features:
    path: features
```

### Creating a New Feature

1. **Use the template**: Copy an existing feature (like `counter`) as a starting point.
2. **Rename files and classes**: Update all references to match your feature name.
3. **Implement layers**:
    - `data/`: Implement data sources and repositories.
    - `domain/`: Define entities, repository interfaces, and use cases.
    - `presentation/`: Build UI and state management logic.
4. **Set up DI**: Use `@injectable`, `@lazySingleton`, or `@factory` annotations on your classes.
5. **Register Exports**:
    - Add your internal files to `{feature_name}_export.dart`.
    - Export the feature from the root `lib/export_features.dart`.
6. **Generate Code**: Run `build_runner` to update the DI configuration.

## 🏗️ Dependency Injection

This library uses `injectable` for automated dependency injection.

- **Implementation**: Annotate your implementation classes (e.g., `@LazySingleton(as: MyRepository)`).
- **Core Config**: Located in `lib/core/di/di.dart`.
- **Async Deps**: Use `@preResolve` in `ExternalModule` (e.g., for `SharedPreferences`).

## 🧪 Testing

Each feature should include tests for:

- Data layer (repositories, data sources)
- Domain layer (use cases, entities)
- Presentation layer (widgets, controllers)

Example test structure:

```
test/
  ├── {feature_name}_test/
  │   ├── data/
  │   ├── domain/
  │   └── presentation/
  └── test_helpers/     # Test utilities and mocks
```

## 📦 Dependencies

Core dependencies used across features:

- `get_it`: Service locator
- `injectable`: Code generation for dependency injection
- `equatable`: Value equality
- `dio`: HTTP client
- `flutter_bloc`: State management
- `shared_preferences`: Local storage

## 🔄 State Management

Features should use `Bloc` or `Cubit` for state management to maintain consistency across the project.

## 📝 Code Generation

Run build_runner after making changes to DI or JSON serialization:

```bash
cd features
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🔗 Related Libraries

- `cc_sdk_ui`: UI component library used across apps and features.
  See [cc_core_sdk/cc_sdk_ui/README.md](../cc_core_sdk/cc_sdk_ui/README.md) for usage and examples.
- `cc_sdk`: Core SDK utilities and shared services used by features.
  See [cc_core_sdk/cc_sdk/README.md](../cc_core_sdk/cc_sdk/README.md).
