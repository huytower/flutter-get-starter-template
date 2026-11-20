/// Regional settings detected by the app (device region, GPS) that the shell
/// applies, such as the UI language.
///
/// ```dart
/// getIt<RegionalSettingsContract>().detectedLanguageCode.listen(setLocale);
/// ```
abstract interface class RegionalSettingsContract {
  /// Emits the language code (e.g. `vi`) matching a newly detected region.
  /// Regions without a mapped language emit nothing.
  Stream<String> get detectedLanguageCode;
}
