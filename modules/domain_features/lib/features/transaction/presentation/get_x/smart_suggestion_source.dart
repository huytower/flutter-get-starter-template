import 'package:flutter/widgets.dart';

import '../../domain/entities/transaction_entity.dart';

class SmartSuggestion {
  const SmartSuggestion({
    required this.match,
    required this.icon,
    required this.hintKey,
  });

  final TransactionEntity match;
  final IconData icon;
  final String hintKey;
}

abstract interface class SmartSuggestionSource {
  SmartSuggestion? get activeSuggestion;

  String get suggestionCurrencyCode;

  Future<void> applyActiveSuggestion();

  void dismissActiveSuggestion();
}
