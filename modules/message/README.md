# Message Module

A Flutter module for handling internationalization (i18n) and localization using the `easy_localization` package.

## Features

- Multi-language support
- Multi-locale configuration
- Easy string translation
- Pluralization support
- RTL (Right-to-Left) language support
- Fallback locale handling

## Getting Started

### Prerequisites

- Flutter SDK
- `easy_localization` package (included as a dependency)

### Installation

1. Add this module to your `pubspec.yaml`:

```yaml
dependencies:
  content_locale:
    path: modules/message
```

2. Run `flutter pub get`

### Project Structure

```
modules/
  message/
    lib/
      cc_localization.  # Main localization service
    assets/
      translations/         # Translation files
        en.json            # English translations
        vi.json            # Vietnamese translations
        # Add more language files as needed
```

### Usage

1. **Initialize Localization**

In your `main.dart`, follow the **Turbo Parallel Boot** pattern:

```
import 'package:message/cc_localization.' as localization;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Part of parallel boot sequence
  await Future.wait([
    // ... other parallel inits
    localization.CcLocalization.initialize(),
    // ... other parallel inits
  ]);
  
  runApp(
    localization.CcLocalization.wrapWithLocalization(
      child: const MyApp(),
    ),
  );
}
```

2. **Using Translations**

```
// In your widget
Text('hello_world'.tr())

// With parameters
Text('welcome_message'.tr(namedArgs: {'name': 'John'}))

// Pluralization
Text('items_count'.plural(5))
```

3. **Changing Locale**

```
// To change language
await context.setLocale(const Locale('vi'));  // Switch to Vietnamese
```

### Adding New Translations

1. Add your translation strings to the corresponding JSON files in `assets/translations/`:

`en.json`:

```json
{
  "hello_world": "Hello World!",
  "welcome_message": "Welcome, {name}!",
  "items_count": "{count} items | {count} item | {count} items"
}
```

2. Add the new language code to `supportedLocales` in `cc_localization.` if needed.

## Best Practices

- Keep translation keys in snake_case
- Group related translations in nested JSON objects
- Use named parameters for dynamic content
- Always provide a default/fallback translation in English
- Test with RTL languages if your app supports them

## Troubleshooting

- If translations don't appear, ensure:
    - The JSON files are properly formatted
    - The asset paths in `pubspec.yaml` are correct
    - The locale is properly set and supported

## Dependencies

- [easy_localization](https://pub.dev/packages/easy_localization) - For internationalization and localization
