# CC SDK UI

A comprehensive UI component library for Flutter applications, designed to work seamlessly with `cc_sdk`. This package
is part of the **Hybrid-Shell Super App Architecture**, providing responsive, design-system-aligned widgets.

**Architecture Note**: All widgets are state-management agnostic and follow responsive-first design for the Multi-Screen support in the Hybrid-Shell architecture.

## Features

### UI Components

- **Buttons**: Various button styles including `CcCloseBtn`, `CcDebounce`, `CcBaseBtn`
- **Dialogs**: Ready-to-use dialogs and bottom sheets
- **Form Elements**: Input fields, text fields, and form validators
- **Loaders & Indicators**: Loading spinners, progress indicators, and skeleton loaders
- **Layout Components**: Flexible containers, cards, and dividers
- **Text & Typography**: Custom text widgets with consistent styling
- **Animations**: Common animations like fade, scale, and custom transitions

### Key Utilities

- **Widget Extensions**: Helpful extensions for common widget operations
- **Theme Support**: Easy theming and styling utilities
- **Responsive Design**: Components that adapt to different screen sizes
- **Form Handling**: Utilities for form validation and state management

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  cc_sdk_ui:
    path: libraries/cc_sdk_ui
  cc_sdk:  # Required core functionality
    path: libraries/cc_sdk
```

## Usage

### Basic Button Example

```dart
import 'package:cc_sdk_ui/widgets/button/cc_close_btn.dart';

CcCloseBtn(
  onTap: () {
    // Handle button press
  },
  icon: Icon(Icons.close),
  bgColor: CcBaseColors.actionPrimary,
)
```

### Text Field with Validation

```dart
import 'package:cc_sdk_ui/widgets/text_field/base_text_field.dart';

BaseTextField(
  hintText: 'Enter your name',
  controller: _nameController,
  onChanged: (value) {
    // Handle text changes
  },
  onSubmit: (value) {
    // Handle form submission
  },
)
```

### Loading Indicator

```dart
import 'package:cc_sdk_ui/widgets/api/loading_widget.dart';

LoadingPageWidget(
  child: YourContentWidget(),
)
```

### Theme Token Usage

Use the color and typography tokens in app theme definitions or custom widgets:

```dart
Text(
  'Welcome',
  style: TextStyle(
    fontSize: CcTypographyParams.titleLarge,
    fontWeight: CcTypographyParams.medium,
    color: CcBaseColors.textPrimary,
  ),
)
```

If you want app-level theme integration, consume `PrjColors` from `modules/theme` and `Theme.of(context).colorScheme` in
widgets instead of hardcoded values.

## Dependencies

- `cc_sdk`: Core functionality and utilities
- `flutter_svg`: For SVG image support
- `google_fonts`: For custom typography
- `custom_refresh_indicator`: For pull-to-refresh functionality
- `mask_text_input_formatter`: For input masking
- `shimmer`: For loading placeholders

## Customization

### Theming

You can customize the look and feel by overriding the default theme:

```dart
MaterialApp(
  theme: ThemeData(
    // Your theme overrides
    primarySwatch: Colors.blue,
    // ...
  ),
  // ...
)
```