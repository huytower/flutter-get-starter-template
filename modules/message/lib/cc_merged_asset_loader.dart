import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

import 'cc_locale_keys.dart';

/// Loads the app's own translations ([CodegenLoader.mapLocales]) merged with
/// translations shipped by reusable packages (e.g. `CcMfTranslations` from
/// cc_micro_features), so a shared package can own its strings without
/// depending on this app-specific module.
///
/// Merge order: package maps first (in list order), then the app's map, so the
/// app can override any package string by defining the same key. A package
/// that lacks the requested locale contributes its `en` map instead.
class CcMergedAssetLoader extends AssetLoader {
  const CcMergedAssetLoader({this.packageTranslations = const []});

  /// Each entry is a package's `locale code -> translations` map.
  final List<Map<String, Map<String, dynamic>>> packageTranslations;

  static const String _fallbackLocale = 'en';

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    final localeKey = locale.toString();
    final appMap = CodegenLoader.mapLocales[localeKey];
    if (packageTranslations.isEmpty) return Future.value(appMap);

    final merged = <String, dynamic>{};
    for (final package in packageTranslations) {
      final packageMap = package[localeKey] ?? package[_fallbackLocale];
      if (packageMap != null) _deepMerge(merged, packageMap);
    }
    if (appMap != null) _deepMerge(merged, appMap);
    return Future.value(merged);
  }

  static void _deepMerge(Map<String, dynamic> target, Map<String, dynamic> source) {
    source.forEach((key, value) {
      final existing = target[key];
      if (value is Map<String, dynamic> && existing is Map<String, dynamic>) {
        _deepMerge(existing, value);
      } else if (value is Map<String, dynamic>) {
        // Copy so later merges never mutate a package's const map.
        final copy = <String, dynamic>{};
        _deepMerge(copy, value);
        target[key] = copy;
      } else {
        target[key] = value;
      }
    });
  }
}
