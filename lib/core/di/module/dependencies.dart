import 'package:app_config/data/datasource/local/box/app_storage/cc_app_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:theme/presentation/provider/theme_provider.dart';

/// Provides routing-layer dependencies that originate from external packages.
@module
abstract class Dependencies {
  /// Single [ThemeProvider] instance shared across all routing strategies.
  @lazySingleton
  ThemeProvider provideThemeProvider() => ThemeProvider(
    initialDarkMode: CcAppStorage.instance.isDarkMode,
  );
}
