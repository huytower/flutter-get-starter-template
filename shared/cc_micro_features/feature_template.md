# Feature Template

This document outlines the standard structure and implementation guidelines for creating new features in the
Hybrid-Modular Super App architecture. All features follow **Clean Architecture** with **Turbo Boot** performance
requirements (startup < 2s).

## Architecture Layer

Features are organized by purpose in two locations:

- **Micro-Features** (`cc_micro_features/lib/features/`): Reusable, project-blind features (Auth, Biometric, etc.)
- **Domain Features** (`modules/domain_features/lib/features/`): App-specific business verticals (Home, Comment, Wallet)

## Directory Structure

```
features/
└── lib/
    └── {feature_name}/           # Lowercase with underscores
        ├── data/
        │   ├── datasources/      # Data sources (API, local storage, etc.)
        │   └── repositories/     # Repository implementations — annotated in place, no per-feature di/ folder
        │
        ├── domain/
        │   ├── entities/         # Business objects
        │   ├── repositories/     # Abstract repository contracts
        │   └── usecases/        # Business logic
        │
        └── presentation/
            ├── pages/           # Feature screens
            └── widgets/         # Reusable UI components
```

## File Templates

### 1. Data Layer

#### `data/datasources/{feature_name}_datasource.dart`

```dart
import '../../domain/entities/feature_name_entity.dart';

abstract class FeatureNameDatasource {
  Future<FeatureNameEntity> getData();
// Add other data source methods
}
```

#### `data/repositories/{feature_name}_repository_impl.dart`

See [Section 4 (Dependency Injection)](#4-dependency-injection) below for the full, DI-annotated version of
this file — the repository implementation and its `@LazySingleton` annotation are written together, not added
as a separate step.

### 2. Domain Layer

#### `domain/entities/{feature_name}_entity.dart`

```dart
class FeatureNameEntity {
  final String id;

  // Add other properties

  const FeatureNameEntity({
    required this.id,
    // Initialize other properties
  });

// Add copyWith, toJson, fromJson if needed
}
```

#### `domain/repositories/{feature_name}_repository.dart`

```dart
import '../entities/feature_name_entity.dart';

abstract class FeatureNameRepository {
  Future<FeatureNameEntity> getData();
// Add other repository methods
}
```

#### `domain/usecases/{feature_name}_usecase.dart`

```dart
import '../entities/feature_name_entity.dart';
import '../repositories/feature_name_repository.dart';

class FeatureNameUseCase {
  final FeatureNameRepository repository;

  FeatureNameUseCase(this.repository);

  Future<FeatureNameEntity> execute() async {
    return await repository.getData();
  }
}
```

### 3. Presentation Layer

#### `presentation/pages/{feature_name}_page.dart`

```dart
import 'package:flutter/material.dart';
import '../widgets/feature_name_widget.dart';

class FeatureNamePage extends StatelessWidget {
  const FeatureNamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feature Name')),
      body: const FeatureNameWidget(),
    );
  }
}
```

#### `presentation/widgets/feature_name_widget.dart`

```dart
import 'package:flutter/material.dart';

class FeatureNameWidget extends StatelessWidget {
  const FeatureNameWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement your ui UI here
    return const Center(
      child: Text('Feature Name Widget'),
    );
  }
}
```

### 4. Dependency Injection

**CRITICAL**: There is no per-feature DI module file. DI is registered **per package**, once, at
`lib/core/di/di.dart` (e.g. `modules/domain_features/lib/core/di/di.dart`,
`shared/cc_micro_features/lib/core/di/di.dart`), via a single `@InjectableInit.microPackage()`-annotated
`initMicroPackage()` function. That function scans the whole package for `@injectable`/`@lazySingleton`
annotations — you do NOT write a `@module abstract class` per feature.

Instead, annotate each class directly where it's defined:

#### `data/repositories/feature_name_repository_impl.dart`

```dart
import 'package:injectable/injectable.dart';

import '../../domain/repositories/feature_name_repository.dart';
import '../datasources/feature_name_datasource.dart';

@LazySingleton(as: FeatureNameRepository) // Always @lazySingleton (never eager @singleton) — Turbo Boot < 2s
class FeatureNameRepositoryImpl implements FeatureNameRepository {
  FeatureNameRepositoryImpl(this._datasource);

  final FeatureNameDatasource _datasource;

  @override
  Future<FeatureNameEntity> getData() => _datasource.getData();
}
```

Then run `melos run gen` (or `dart run build_runner build --delete-conflicting-outputs` from the package
root) to regenerate `di.module.dart` — the package's existing `core/di/di.dart` file does not change per
feature, only the generated output does.

## Integration

### 1. Update Features Exports

For **Micro-Features** (`cc_micro_features`): Add your feature exports to `lib/export_micro_features.dart`:

```dart
library micro_features;

// Feature exports
export 'features/auth/export_auth.dart';
export 'features/{feature_name}/presentation/pages/{feature_name}_page.dart'; // Add this line
```

For **Domain Features** (`modules/domain_features`): Add to `lib/export_domain_features.dart`.

### 2. Register Dependencies

Nothing to do here per feature — the package's existing `lib/core/di/di.dart` (one file, package-wide) already
scans all `@lazySingleton`/`@injectable`-annotated classes via `@InjectableInit.microPackage()`. Just run
`melos run gen` after adding your annotated classes so `di.module.dart` picks them up. See [Section 4](#4-dependency-injection)
above for the exact annotation to use.

The main App Shell consolidates all packages' DI in `lib/core/di/di.dart` via `@InjectableInit` with
`externalPackageModulesBefore` — you don't need to touch this file when adding a feature.

## Best Practices

1. **Naming Conventions**:
    - Use `snake_case` for file names
    - Use `PascalCase` for class names
    - Keep feature names consistent across all layers

2. **State Management**:
    - Use GetX, Bloc, or Provider consistently
    - Keep business logic in use cases
    - Keep UI state in controllers/blocs

3. **Testing**:
    - Create test files for each layer
    - Mock dependencies using Mockito or Mocktail
    - Test both success and error cases

4. **Documentation**:
    - Add doc comments for public APIs
    - Document complex business logic
    - Include example usage in documentation

## Example: Creating a New Feature

1. Study the `wallet` feature (`modules/domain_features/lib/features/wallet/`) as the up-to-date reference —
   it follows every convention in this document and in `AGENTS.md`. Do not copy structure from
   `modules/domain_features/lib/features/examples/` — that folder is tutorial/demo scaffolding, not a pattern
   to replicate.
2. Create the new feature folder and rename files/classes to match.
3. Implement the data layer (datasources, repositories), annotating repositories `@LazySingleton(as: ...)` in place.
4. Define domain entities, repository interfaces, and use cases.
5. Build the UI in the presentation layer, following the design-system and responsiveness rules in `AGENTS.md`.
6. Run `melos run gen` to regenerate DI.
7. Add feature exports to `export_micro_features.dart` / `export_domain_features.dart`.
8. Run `melos run analyze`.

## See Also

- [Wallet Feature Example](../../modules/domain_features/lib/features/wallet)
- [AGENTS.md — canonical AI/contributor rulebook](../../AGENTS.md)
- [Project Clean Architecture Guidelines](../../docs/CONTRIBUTING.md)
