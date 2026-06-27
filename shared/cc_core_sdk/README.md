# cc_core_sdk

A collection of reusable Flutter packages for mobile application development.

## Packages

This repository contains the following Flutter packages:

### cc_mixin

Provides reusable Dart mixins for common functionality across Flutter applications.

### cc_sdk

Core Flutter utility package that provides various extensions, helpers, and utilities.

**Main Components:**

- **Core Extensions**: Common extensions (list, string), Kotlin-style extensions (list, scope, when expression), UI
  extensions (widget extensions), Utility extensions (logger)
- **Core Utils**: Error handling, Logging, Common utilities (date/time, device, formatting, images, strings, throttling)
- **Helpers**: Alert dialogs, Bottom sheets, Device utilities, Dialog helpers, Widget helpers
- **Constants**: Multimedia constants, Number format parameters, Padding parameters, Log tags

### cc_sdk_ui

UI component library providing reusable widgets and UI elements.

**Widget Categories:**

- **Buttons**: Base buttons, social login buttons, action buttons (back, close, delete, done, edit, etc.)
- **Cards**: Base card components, expanded/collapse cards
- **Inputs**: Text fields, phone number inputs, OTP inputs, country code selectors
- **Avatars**: User avatar components
- **Spinners**: Loading indicators and spinners
- **Switches**: Toggle switches
- **Toasts**: Toast notification components
- **Pages**: Error pages, loading pages, status pages (empty, not found, retry, etc.)
- **Dialogs**: Base dialogs, modal bottom sheets, message dialogs
- **Navigation**: Curved navigation bars
- **Extensions**: Context extensions, responsive extensions, widget extensions
- **Helpers**: Dialog helpers, keyboard helpers, snackbar helpers, widget helpers

### cc_sdk_data

Core data entities and models for shared data structures.

## Usage

Add the desired package to your `pubspec.yaml`. 

**Note**: This SDK is designed for high-performance apps. When registering core services (e.g., `CcNetworkInfo`), always use `@lazySingleton` or `@LazySingleton` to ensure the App Shell's **Turbo Boot** remains under 2 seconds.

```yaml
dependencies:
  cc_mixin:
    git:
      url: https://github.com/huytower/cc_core_sdk
      path: cc_mixin
  cc_sdk:
    git:
      url: https://github.com/huytower/cc_core_sdk
      path: cc_sdk
  cc_sdk_ui:
    git:
      url: https://github.com/huytower/cc_core_sdk
      path: cc_sdk_ui
  cc_sdk_data:
    git:
      url: https://github.com/huytower/cc_core_sdk
      path: cc_sdk_data
```

## Development

This repository is designed to be used as a git submodule in Flutter projects. The packages follow a modular
architecture to promote code reusability and maintainability.

To synchronize with remote:

```
bash
git submodule update --remote cc_core_sdk
```

To push changes to the cc_core_sdk submodule:

```
bash
# Navigate to submodule and make changes
cd cc_core_sdk
# Make your changes...

# Commit changes
git add .
git commit -m "Your commit message"

# Push to remote
git push origin main

# Go back to main project
cd ..

# Update submodule reference in main project
git add cc_core_sdk
git commit -m "Update cc_core_sdk submodule"
git push origin main
```