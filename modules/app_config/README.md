# App Config Module

A comprehensive configuration module for Flutter applications that handles application settings, environment
configurations, and dependency management.

## Features

- **Application Configuration**
    - Version and build information
    - Environment-specific settings
    - Feature flags and toggles
    - Global application constants

- **Dependency Injection**
    - Centralized dependency registration
    - Environment-aware service configuration
    - Lazy loading support

- **Local Storage**
    - Hive-based storage
    - Type-safe data access
    - Automatic serialization

## Getting Started

### 1. Installation

Add the module to your `pubspec.yaml`:

```yaml
dependencies:
  app_config:
    path: modules/app_config
```

### 2. Initialization

In your `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await initializeDependencies();
  
  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await registerHiveAdapter();
  
  // Set up localization
  await CcLocalization.setLocale('en');
  
  runApp(const AppRunner());
}
```

## Usage

### Accessing App Configuration

```
final version = await CcAppConfig.version;
final buildNumber = await CcAppConfig.buildNumber;
```

### Using AppVersionService

```
final appVersionService = getIt<AppVersionService>();
final needsUpdate = await appVersionService.isUpdateRequired('1.2.0');
```

### Environment Configuration``

Environment variables are loaded from `.env` files in the `env/` directory:

- `.env` - Development environment
- `.env.uat` - UAT environment
- `.env.production` - Production environment

## Dependency Injection

The module uses `get_it` with `injectable` for dependency management. To regenerate injection code after adding new
dependencies:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Hive Storage

### Defining Models

```dart
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  UserModel({required this.id, required this.name});
}
```

### Registering Adapters

In `main.dart`:

```
Hive.registerAdapter(UserModelAdapter());
```

## Feature Flags

Control feature availability using `CcFeatureFlags`:

```dart
if (CcFeatureFlags.isEnableLogger) {
  // Logger is enabled
}
```

## Contributing

1. Follow the existing code style
2. Add tests for new features
3. Update documentation
4. Submit a pull request

## Dependencies

- [hive](https://pub.dev/packages/hive) - Lightweight and fast key-value storage
- [get_it](https://pub.dev/packages/get_it) - Service locator
- [injectable](https://pub.dev/packages/injectable) - Dependency injection
- [package_info_plus](https://pub.dev/packages/package_info_plus) - App version info
