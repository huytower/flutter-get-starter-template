import 'currency_selection_sources.dart';

enum CurrencySelectionSourceType {
  detected,
  userSelected,
  migrated;

  static CurrencySelectionSourceType parse(String? value) {
    return switch (CurrencySelectionSources.validate(value)) {
      CurrencySelectionSources.detected => CurrencySelectionSourceType.detected,
      CurrencySelectionSources.userSelected =>
        CurrencySelectionSourceType.userSelected,
      _ => CurrencySelectionSourceType.migrated,
    };
  }
}

