import '../constant/currency_catalog.dart';

typedef AiPromptCategory = ({String id, String label, String type});
typedef AiPromptWallet = ({String id, String name});

class SmartEntryContext {
  const SmartEntryContext({
    required this.types,
    required this.categories,
    required this.wallets,
    required this.currency,
    required this.language,
    required this.today,
  });

  final List<String> types;
  final List<AiPromptCategory> categories;
  final List<AiPromptWallet> wallets;
  final CurrencyDefinition currency;
  final String language;
  final DateTime today;

  bool get isMixed => types.length > 1;

  String get defaultType => types.first;
}
