# Feature Template

This document outlines the standard structure and implementation guidelines for creating new features in the
application.

## Directory Structure

```
features/
└── lib/
    └── {feature_name}/           # Lowercase with underscores
        ├── data/
        │   ├── datasources/      # Data sources (API, local storage, etc.)
        │   └── repositories/     # Repository implementations
        │
        ├── di/                   # Dependency injection setup
        │   └── {feature_name}_module.dart
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
import 'package:features/counter_export.dart';

abstract class FeatureNameDatasource {
  Future<FeatureNameEntity> getData();
  // Add other data source methods
}
```

#### `data/repositories/{feature_name}_repository_impl.dart`

```dart
import 'package:features/counter_export.dart';

class FeatureNameRepositoryImpl implements FeatureNameRepository {
  final FeatureNameDatasource datasource;

  FeatureNameRepositoryImpl(this.datasource);

  @override
  Future<FeatureNameEntity> getData() async {
    return await datasource.getData();
  }
}
```

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

#### `di/feature_name_module.dart`

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/di/di.dart';
import '../data/datasources/feature_name_datasource.dart';
import '../data/repositories/feature_name_repository_impl.dart';
import '../domain/repositories/feature_name_repository.dart';
import '../domain/usecases/feature_name_usecase.dart';

@module
abstract class FeatureNameModule {
  @lazySingleton
  FeatureNameDatasource get dataSource => FeatureNameDatasourceImpl();

  @lazySingleton
  FeatureNameRepository get repository => 
      FeatureNameRepositoryImpl(getIt<FeatureNameDatasource>());

  @injectable
  FeatureNameUseCase get useCase => 
      FeatureNameUseCase(getIt<FeatureNameRepository>());
}
```

## Integration

### 1. Update Features Exports

Add your feature exports to `lib/export_features.dart`:

```dart
library features;

// Core exports
export 'common/constants/app_constants.dart';
export 'common/di/di.dart';

// Feature exports
export 'counter/presentation/pages/counter_page.dart';
export 'feature_name/presentation/pages/feature_name_page.dart';  // Add this line
```

### 2. Register Dependencies

Update `core/di/di.dart` to include your feature module:

```dart
@injectableInit
void configureDependencies() {
  // Register feature modules
  getIt.registerSingleton(FeatureNameModule());
  
  // Initialize other dependencies
  $initGetIt(getIt);
}
```

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

1. Copy the counter feature as a template
2. Rename files and classes to match your feature name
3. Implement the data layer (datasources, repositories)
4. Define domain entities and use cases
5. Build the UI in the presentation layer
6. Set up dependency injection
7. Add feature exports to `export_features.dart`
8. Register dependencies in `di.dart`

## See Also

- [Counter Feature Example](/features/lib/counter)
- [Project Architecture Documentation](/doc/ARCHITECTURE.md)
- [Coding Guidelines](/doc/CODING_GUIDELINES.md)
