# AI Context - Flutter Get Starter Template

## Project Overview

Flutter starter template following **Clean Architecture** and **SOLID principles** with modular structure.

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

## Project Structure

```
flutter-get-starter-template/
├── lib/                          # Main app code
│   ├── core/                     # Core app logic
│   ├── data/                     # Data layer
│   ├── presentation/             # UI layer
│   └── main*.dart               # Entry points (prod, uat, logging, free)
├── modules/                      # App-specific modules
│   ├── app_config/              # Configuration, DI, storage
│   ├── data/                    # Data sources, repositories, entities
│   ├── message/                 # i18n/localization
│   └── theme/                   # Theming system
├── libraries/                    # Reusable libraries
│   ├── cc_sdk/                  # Core SDK (network, device, failures)
│   ├── cc_sdk_ui/               # UI component library
│   └── features/                # Modular feature packages
└── docs/                        # Documentation
```

## Core Libraries

### libraries/cc_sdk (Core SDK)
**Purpose:** Essential functionality and utilities

**Key Components:**
- Network utilities (CURL, interceptors, connectivity)
- Device information
- Common extensions and helpers
- Serialization (GSON-style)
- Error handling with Failure types
- Clean Architecture implementation

**Architecture Flow:**
1. **Domain Layer**: UseCases (business logic) + Repository Interfaces (contracts)
2. **Data Layer**: Repository Implementations (managers) + DataSources (laborers)
3. **Core Layer**: Standardized failures (NetworkFailure, ServerFailure, AppConfigFailure)

**Dependencies:** connectivity_plus, dio, device_info_plus, crypto, equatable, google_fonts, intl, multiple_result, package_info_plus

### libraries/cc_sdk_ui (UI Components)
**Purpose:** Reusable, customizable UI components

**Components:**
- Buttons: CcCloseBtn, CcDebounce, CcBaseBtn
- Dialogs and bottom sheets
- Form elements (text fields, validators)
- Loaders & indicators (spinners, skeletons)
- Layout components (containers, cards, dividers)
- Text & typography widgets
- Animations (fade, scale, transitions)

**Theme Tokens:**
- `BaseColors`: Color palette (brand, neutral, semantic)
- `CcTypographyParams`: Typography system (sizes, weights)

**Dependencies:** cc_sdk, flutter_svg, google_fonts, custom_refresh_indicator, mask_text_input_formatter, shimmer

### libraries/features (Feature Modules)
**Purpose:** Modular, reusable feature packages

**Structure per feature:**
```
{feature_name}/
├── data/
│   ├── datasources/          # API, local storage
│   └── repositories/         # Repository implementations
├── di/
│   └── {feature_name}_module.dart  # Feature-specific DI
├── domain/
│   ├── entities/             # Business objects
│   ├── repositories/         # Repository contracts
│   └── usecases/            # Business logic
└── presentation/
    ├── pages/               # Feature screens
    └── widgets/             # Reusable UI components
```

**Dependencies:** get_it, injectable, equatable, dio, shared_preferences

## App Modules

### modules/app_config
**Purpose:** Application configuration and dependency management

**Features:**
- Version and build information
- Environment-specific settings (.env files)
- Feature flags and toggles
- Global application constants
- Centralized dependency registration
- Hive-based local storage with type adapters

**Environment Files:**
- `.env` - Development
- `.env.uat` - UAT
- `.env.production` - Production

**Dependencies:** hive, get_it, injectable, package_info_plus

### modules/data
**Purpose:** Data layer configuration and implementation

**Features:**
- Remote server configuration (Retrofit)
- Server response handling
- JSON parsing
- Local database (Floor)
- Repository pattern

**Key Files:**
- `injection.dart`: DI initialization
- `data_module.dart`: Server URL configuration
- `response.dart`: JSON parser and response handler
- `/datasource`: API definitions with Retrofit
- `/entities`: Data models with @JsonSerializable()
- `/repositories`: Data storage implementations

**Dependencies:** retrofit, floor, json_serializable, injectable

### modules/theme
**Purpose:** Theming system with Clean Architecture

**Structure:**
- `core/`: Low-level theme configuration and helpers
  - `config/cc_themes.dart`: ThemeData definitions
  - `utils/theme_utils.dart`: ColorScheme builders
- `data/`: Data sources, color tokens
  - `data_source/color/prj_color.dart`: Maps to cc_sdk_ui BaseColors
- `presentation/`: UI-facing styles
  - `style/cc_text_style.dart`: ThemeExtension for TextTheme
  - `provider/`: Theme provider for runtime selection

**Design Principles:**
- Single Source of Truth: cc_sdk_ui exports BaseColors and CcTypographyParams
- Theme-level usage: Use Theme.of(context).textTheme and colorScheme
- Central tokens: Update primitives in cc_sdk_ui

**Dependencies:** cc_sdk_ui

### modules/message
**Purpose:** Internationalization (i18n) and localization

**Features:**
- Multi-language support
- Multi-locale configuration
- Easy string translation
- Pluralization support
- RTL language support
- Fallback locale handling

**Structure:**
```
modules/message/
├── lib/cc_localization.dart    # Main localization service
└── assets/translations/         # Translation files
    ├── en.json                 # English
    └── vi.json                 # Vietnamese
```

**Dependencies:** easy_localization

## Key Technologies

### Dependency Injection
- **get_it**: Service locator
- **injectable**: Code generation for DI
- **Annotations**: @injectable, @module, @preResolve, @named, @singleton, @lazySingleton

### State Management
- **GetX**: State management, routing, dependency injection
- **Bloc**: State management with streams
- **Provider**: State management (alternative)

### Networking
- **Retrofit**: Type-safe HTTP client with annotations
- **Dio**: HTTP client with interceptors

### Storage
- **Hive**: Fast, lightweight NoSQL database
- **Floor**: SQLite ORM with automatic mapping
- **SharedPreferences**: Simple key-value storage

### Code Generation
- **build_runner**: Code generation runner
- **json_serializable**: JSON serialization/deserialization
- **injectable**: DI code generation

### UI & Utilities
- **flutter_hooks**: Code sharing between widgets, animations
- **flutter_svg**: SVG image support
- **google_fonts**: Custom typography
- **shimmer**: Loading placeholders

## Coding Standards

### Clean Architecture Rules
- **Domain layer** must not depend on Data or Presentation layers
- **Data layer** depends on Domain layer (repository interfaces)
- **Presentation layer** depends on Domain layer (use cases)
- Use dependency injection to invert dependencies

### SOLID Principles
- Each class should have a single responsibility
- Use interfaces/abstract classes for contracts
- Depend on abstractions, not concretions
- Use dependency injection extensively

### Naming Conventions
- Feature names: lowercase with underscores (e.g., `user_profile`)
- Classes: PascalCase (e.g., `UserProfileRepository`)
- Files: snake_case (e.g., `user_profile_repository.dart`)
- Private members: prefix with underscore (e.g., `_privateMethod`)

### Annotations
- Use `@JsonSerializable()` for data models
- Use `@injectable`, `@singleton`, `@lazySingleton` for DI
- Use `@RestApi()` for Retrofit clients
- Use `@HiveType()`, `@HiveField()` for Hive models

## Adding New Code

### UI Implementation: The 2-Location Rule
To prevent confusion and "decision fatigue," all UI components must live in ONLY one of these two places:

1. **Design System (`libraries/cc_sdk_ui`)**: 
   - **What**: Generic, highly reusable widgets with NO business logic.
   - **Criteria**: If you can use it in a different app, it goes here.
   - **Examples**: `CcButton`, `CcTextField`, `CcDialog`, `LoadingScreen`.

2. **Feature Widgets (`lib/presentation/pages/[feature]/widgets`)**: 
   - **What**: Widgets specific to a single feature or page.
   - **Criteria**: If it's part of a specific user requirement (e.g., "Home User Card"), it goes here.
   - **Examples**: `HomeHeader`, `LoginSubmitButton`, `ProfileAvatar`.

**Note**: If a widget is shared between two features but isn't a "Design System" component, prefer moving it to `cc_sdk_ui` and making it generic, or keep it in the feature that "owns" it. **`modules/widget` has been removed to simplify the architecture.**

---

### Content Localization: The Global Dictionary Way
To keep multi-language support simple and avoid hunting for text in widgets, we use a **Single Source of Truth** for all strings.

1. **The Dictionary (One Place)**: All translation files live **ONLY** in `modules/message/assets/translations/` (e.g., `en.json`, `vi.json`).
2. **The Key (The ID)**: Every piece of text has a unique ID with a prefix (e.g., `sdk.no_data`, `auth.login`).
3. **The Workflow**:
   - **Step 1**: Add your key and translation to the JSON files in `modules/message`.
   - **Step 2**: Use it in **any** widget (Root, Library, or Module) by typing `'key.id'.tr()`.

**Rule**: Never hardcode strings in the UI. Always use the Global Dictionary.

---

### Development Decision Tree

| Requirement Type | Target Location |
| :--- | :--- |
| **General UI Component** | `libraries/cc_sdk_ui/` |
| **Screen / Feature UI** | `lib/presentation/pages/[feature]/` |
| **Business Logic (Use Case)**| `lib/domain/usecases/` |
| **Infrastructure / Config** | `modules/app_config/` |
| **Data / API / Models** | `modules/data/` |

**Reusable Features** (to be shared across projects):
- Use `libraries/features/` - Follow the Clean Architecture structure (data/domain/presentation)
- Set up DI in `di/{feature_name}_module.dart`
- Export from `lib/features.dart`

**App-Specific Features** (unique to this project):
- Data operations → `modules/data/` (datasource, entities, repositories)
- UI components (reusable) → `libraries/cc_sdk_ui/`
- Configuration → `modules/app_config/`
- Theming → `modules/theme/`
- Localization → `modules/message/`

### Integration Steps

1. **Create the feature structure** following Clean Architecture layers
2. **Add DI annotations** (@injectable, @module, @singleton, etc.)
3. **Register in appropriate module** (data_module.dart, feature module, etc.)
4. **Run build_runner** to generate DI code: `flutter pub run build_runner build --delete-conflicting-outputs`
5. **Import and use** in presentation layer

### Entry Points

- `main.dart` - Production build
- `main_uat.dart` - UAT environment
- `main_logging.dart` - Debug with logging
- `main_free.dart` - Free tier build

Each entry point initializes:
- Dependency injection
- Hive storage
- Localization
- Theme provider

## Routing & Navigation

### Strategy Pattern
The app uses a **Strategy Pattern** for routing, allowing runtime selection between routing frameworks.

**Key Files:**
- `lib/data/datasource/route_strategy.dart`: Abstract `RoutingStrategy` + implementations
- `lib/core/navigation/route_strategy_provider.dart`: Strategy factory with `RouteStrategyProvider`
- `lib/core/navigation/config/auto_route/app_router.dart`: AutoRoute configuration (default)
- `lib/core/navigation/config/getx/getx_router.dart`: GetX route configuration

**Available Strategies:**
| Strategy | Class | Router | Use When |
| :--- | :--- | :--- | :--- |
| **AutoRoute** (default) | `AutoRouteStrategy` | `AppRouter` | Type-safe routing with code generation |
| **GetX** | `GetxRouteStrategy` | `GetxRoutingManager` | Lightweight routing with GetX bindings |

**Route Registration:**
- Page names are defined in `PageNameEnum` (app pages) and `PageNameByRouteStrategyEnum` (strategy-specific sample pages)
- Route paths are auto-generated from enum names: `getPageName(PageNameEnum.HOME)` → `"/home"`

**Adding a New Route:**
1. Add entry to `PageNameEnum` (or `PageNameByRouteStrategyEnum` for sample pages)
2. For **AutoRoute**: Add `AutoRoute(page: YourRoute.page, path: ...)` in `app_router.dart`, then run `build_runner`
3. For **GetX**: Add `GetPage(name: ..., page: () => YourPage(), binding: YourBinding())` in `getx_router.dart`

---

## State Management Guidelines

### Decision Matrix

| Scenario | Recommended | Why |
| :--- | :--- | :--- |
| **Complex async workflows** with multiple states (loading/error/success) | **BLoC/Cubit** | Structured state transitions, testable with `bloc_test`, clear separation of events/states |
| **Simple reactive UI** with minimal state | **GetX** (`GetxController` + `Obx`) | Lightweight, less boilerplate, built-in routing/DI integration |
| **Theme / app-wide config** | **Provider** (`ChangeNotifier`) | Already used for `ThemeProvider`; ideal for simple cross-cutting concerns |
| **Reactive data models** with fine-grained rebuilds | **watch_it** | Integrates with `get_it`, supports `ValueListenable`-based reactivity |

### Implementation Patterns

**BLoC/Cubit Pattern** (preferred for feature logic):
```
lib/presentation/{feature}/
├── bloc/
│   ├── {feature}_bloc.dart       # or {feature}_cubit.dart
│   └── {feature}_state.dart
├── pages/
│   └── {feature}_page.dart
└── widgets/
    └── {feature}_content.dart
```

**GetX Pattern** (for simpler screens):
```
lib/presentation/getx/{feature}/
├── get_x/
│   ├── {feature}_controller.dart
│   └── {feature}_binding.dart
└── ui/
    └── {feature}_page.dart
```

**Rule**: Do not mix state management approaches within the same feature. Pick one per feature and stay consistent.

---

## Testing Strategy

### Test Structure
```
test/
└── presentation/
    └── cubit/
        └── simple_cubit_test.dart    # Example BLoC/Cubit test
```

### Test Types

| Type | Location | Tools | What to Test |
| :--- | :--- | :--- | :--- |
| **Unit Tests** | `test/` (mirrors `lib/` structure) | `flutter_test`, `bloc_test` | Use cases, cubits/blocs, repositories, utilities |
| **Widget Tests** | `test/presentation/` | `flutter_test` | Individual widget rendering, interactions |
| **Integration Tests** | `integration_test/` | `integration_test` package | Full user flows, navigation, DI wiring |

### Testing Conventions
- **File naming**: `{class_name}_test.dart` (e.g., `simple_cubit_test.dart`)
- **Mocking**: Use `MockCubit<State>` from `bloc_test` for BLoC/Cubit mocks; consider adding `mocktail` for general mocking
- **BLoC/Cubit tests**: Use `blocTest<Cubit, State>()` for state transition assertions with `build`, `act`, `seed`, `expect`
- **Group tests** by method name: `group('increase()', () { ... })`

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/presentation/cubit/simple_cubit_test.dart

# Run with coverage
flutter test --coverage
```

### Recommended Test Coverage
- **Domain layer** (use cases): High priority — pure business logic, easy to test
- **Data layer** (repositories, datasources): Mock API responses, verify data transformations
- **Presentation layer** (cubits/blocs): Test state transitions with `bloc_test`
- **UI widgets**: Test key interactions and conditional rendering

---

## Build & Environment Configuration

### Flutter & Dart Versions
- **Dart SDK**: `^3.11.5`
- **Flutter**: `>=3.41.9`
- **Version Manager**: [FVM](https://fvm.app/) (Flutter Version Management)

### Environment Setup
The project supports 3 environments, configured via `.env` files in `env/`:

| Environment | Env File | Enum Value | Entry Point |
| :--- | :--- | :--- | :--- |
| Development | `env/.env.development` | `FREE_FAKE_API` | `main.dart` |
| UAT | `env/.env.uat` | `UAT` | `main_uat.dart` |
| Production | `env/.env.production` | `PROD` | `main_prod.dart` |

**Switching Environments** (PowerShell):
```powershell
# From scripts/ directory
.\set-environment.ps1 -Environment development   # or: uat, production
```
This copies the correct `.env` file to the project root and updates `http_client_config.dart` with the matching enum.

### Code Generation
After modifying DI annotations, data models, routes, or Hive type adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Lint & Analysis
- **Config**: `analysis_options.yaml` (extends `flutter_lints`)
- **Key rules enforced**: `prefer_relative_imports`, `avoid_print`, `prefer_const_constructors`, `sort_pub_dependencies`, `sort_child_properties_last`

```bash
# Run static analysis
flutter analyze

# Auto-fix lint issues
dart fix --apply
```

### Build Commands
```bash
# Debug build
flutter run

# Release build
flutter build apk --release          # Android
flutter build ios --release           # iOS

# Run with specific entry point
flutter run -t lib/main_uat.dart      # UAT environment
flutter run -t lib/main_prod.dart     # Production environment
```

---

## Error Handling

### Failure Types (from cc_sdk)
- `NetworkFailure`: Network connectivity issues
- `ServerFailure`: Server-side errors
- `AppConfigFailure`: Configuration errors
  - `MissingConfigFailure`: Missing configuration key
  - `InvalidConfigFailure`: Invalid configuration value
  - `SecurityConfigFailure`: Security-related issues

---

## Important Notes

- This project uses **modular architecture** - understand the difference between libraries (reusable) and modules (app-specific)
- **cc_sdk** and **cc_sdk_ui** are shared libraries - changes affect all projects using them
- **modules** are app-specific - can be customized without affecting other projects
- **Always follow Clean Architecture** - don't create circular dependencies
- **Use build_runner** after any DI or JSON serialization changes
- **Theme tokens** are the single source of truth - update in cc_sdk_ui, not in individual widgets
