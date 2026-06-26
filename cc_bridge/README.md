# cc_bridge

A bridge module for cross-feature communication and navigation contracts in the Flutter Super App architecture.

## Purpose

The `cc_bridge` module serves as the communication layer between different features and modules in the hybrid-modular architecture. It defines contracts and interfaces that enable loose coupling between components while maintaining type safety and clear communication patterns.

## Architecture Principles

### Interface-Driven Communication
- All cross-module interactions are mediated by contracts defined in `cc_bridge`
- Features depend on abstractions, never on concrete implementations
- Enables true modularity and testability

### Contract Types
- **Coordinators**: Handle navigation flows between features (e.g., `AuthCoordinator`)
- **Contracts**: Define shared state and session management (e.g., `SessionContract`)
- **Providers**: Offer shared logic and utilities across features

### State-Management Agnostic
- Contracts remain independent of specific state management solutions
- Can work with Bloc, GetX, Provider, or any other state management approach
- Focus on communication patterns, not implementation details

## Directory Structure

```
cc_bridge/
├── lib/
│   ├── core/
│   │   └── di/                  # Dependency injection configuration
│   │       ├── di.dart
│   │       └── di.module.dart
│   ├── src/
│   │   ├── navigation/          # Navigation coordinators
│   │   │   ├── auth_coordinator.dart
│   │   │   ├── comment_coordinator.dart
│   │   │   └── home_coordinator.dart
│   │   └── session/             # Session management contracts
│   │       └── session_contract.dart
│   └── export_cc_bridge.dart   # Public API exports
├── pubspec.yaml
└── README.md
```

## Usage

### Defining a Coordinator

```dart
/// Contract for authentication-related navigation.
abstract class AuthCoordinator {
  /// Navigates to the Login screen.
  void navigateToLogin(BuildContext context);

  /// Navigates to the Phone Authentication screen.
  void navigateToPhoneAuth(BuildContext context);

  /// Navigates to the Main/Dashboard screen after successful login.
  void navigateToDashboard(BuildContext context);
}
```

### Implementing a Coordinator

In the App Shell (`lib/core/navigation/coordinators/`):

```dart
@LazySingleton(as: AuthCoordinator)
class AuthCoordinatorImpl implements AuthCoordinator {
  @override
  void navigateToLogin(BuildContext context) {
    context.router.replace(LoginRoute());
  }

  @override
  void navigateToPhoneAuth(BuildContext context) {
    context.router.push(const PhoneAuthRoute());
  }

  @override
  void navigateToDashboard(BuildContext context) {
    context.router.replacePath(CcRouteConfig.mainNavigation);
  }
}
```

### Using a Coordinator in Features

```dart
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthCoordinator _authCoordinator;
  final LoginUseCase _loginUseCase;

  LoginBloc(this._authCoordinator, this._loginUseCase);

  Future<void> _onLoginSubmitted(LoginSubmitted event) async {
    final result = await _loginUseCase(event.credentials);
    result.when(
      success: (_) => _authCoordinator.navigateToDashboard(context),
      failure: (error) => emit(LoginFailure(error.message)),
    );
  }
}
```

## Dependency Injection

The module uses `get_it` with `injectable` for dependency management:

```dart
@InjectableInit.microPackage()
Future<void> initMicroPackage() async {
  getIt.init();
}
```

## Key Contracts

### Navigation Coordinators
- **AuthCoordinator**: Manages authentication flow navigation
- **HomeCoordinator**: Handles home feature navigation
- **CommentCoordinator**: Manages comment feature navigation

### Session Contracts
- **SessionContract**: Defines session management interface

## Benefits

1. **Loose Coupling**: Features communicate via interfaces, not concrete implementations
2. **Testability**: Easy to mock contracts for unit testing
3. **Flexibility**: Implementations can be swapped without affecting consumers
4. **Type Safety**: Compile-time checking of navigation and communication patterns
5. **Maintainability**: Clear separation of concerns and communication patterns

## Integration

Add to your `pubspec.yaml`:

```yaml
dependencies:
  cc_bridge:
    path: cc_bridge
```

Import the public API:

```dart
import 'package:cc_bridge/export_cc_bridge.dart';
```

## Development Guidelines

1. **Contract First**: Always define the interface/contract before implementation
2. **Single Responsibility**: Each coordinator/contract should have one clear purpose
3. **Documentation**: Document all public methods and their expected behavior
4. **Version Compatibility**: Maintain backward compatibility when updating contracts
5. **Testing**: Write tests for both contracts and their implementations

## Related Modules

- **cc_core_sdk**: Core utilities and dependencies
- **cc_micro_features**: Feature modules that use bridge contracts
- **modules/domain_features**: Business-specific features using bridge contracts
