import 'smart_suggestion.dart';

export 'smart_suggestion.dart';

abstract interface class SmartSuggestionSource {
  SmartSuggestion? get activeSuggestion;

  String get suggestionCurrencyCode;

  Future<void> applyActiveSuggestion();

  void dismissActiveSuggestion();
}
