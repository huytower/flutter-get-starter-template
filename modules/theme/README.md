# Theme Module — Clean Architecture & Usage

This module follows a simple, pragmatic Clean Architecture pattern to keep
theme-related code organized, testable and easy to understand for junior
developers.

Structure

- `core/` — low-level theme configuration and helpers
    - `config/cc_themes.dart` — app-level ThemeData definitions
    - `utils/theme_utils.dart` — helpers that create `ColorScheme` and theme builders
- `data/` — data sources, including color tokens that inherit from the UI SDK
    - `data_source/color/prj_color.dart` — maps semantic app colors to `cc_sdk_ui` `CcBaseColors`
- `presentation/` — UI-facing styles and theme extensions
    - `style/cc_text_style.dart` — `ThemeExtension` building the `TextTheme`
    - `provider/` — theme provider for runtime selection

Design principles

- Single Source of Truth: The `cc_sdk_ui` library exports `CcBaseColors` and
  `CcTypographyParams`. `modules/theme` maps semantic `PrjColors` to those tokens.
- Theme-level usage: Widgets should use `Theme.of(context).textTheme` and
  `Theme.of(context).colorScheme` instead of referencing raw color or size values.
- Keep tokens central: update brand or neutral primitives in `cc_sdk_ui` and
  the change propagates across the project.

Quick examples

Use semantic `TextTheme` in widgets (recommended):

```dart
final title = Theme.of(context).textTheme.titleLarge;
Text('Hello', style: title);
```

Create a button using color tokens:

```dart
final colors = Theme.of(context).colorScheme;
ElevatedButton(
  style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
  onPressed: () {},
  child: Text('Continue', style: Theme.of(context).textTheme.labelLarge),
)
```

If you need to update typography or color tokens, change the token in the
`cc_sdk_ui` library (e.g. `CcBaseColors.brand500` or `CcTypographyParams`) and
update `PrjColors` mappings here only if you need app-specific aliases.

# Theme Module

A clean, modular theming solution for Flutter applications, following Clean Architecture and SOLID principles.

## 🎨 Features

- Light and dark theme support
- Material 3 theming
- Custom color palette
- Typography system
- Easy theme switching

## 🚀 Usage

1. Add to your app:

```yaml
dependencies:
  theme:
    path: modules/theme

2. Setup provider:

```

void main() {
runApp(
MultiProvider(
providers: [
ChangeNotifierProvider(create: (_) => ThemeProvider()),
],
child: const MyApp(),
),
);
}

```

3. Use in widgets:

```

// Toggle theme
context.read<ThemeProvider>().toggleTheme();

// Use text style
Text('Hello', style: context.textStyle?.bodyLarge);

```

🎨 Customization
Colors
Edit: lib/data/data_source/color/prj_color.dart

Typography
Edit: 
lib/presentation/style/cc_text_style.dart