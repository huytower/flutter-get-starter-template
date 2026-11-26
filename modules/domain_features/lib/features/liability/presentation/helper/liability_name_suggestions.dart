import 'package:message/export_message.dart';

/// Which name suggestions (`NameSuggestions`) a liability category offers in
/// `AddLiabilitySheet`, borrow and lend alike.
abstract final class LiabilityNameSuggestions {
  /// Liability category id (`CategorySeed`) → its suggestions' translation key.
  static const Map<String, String> _keyByCategoryId = {
    // Borrow
    'd1': PrjLocaleKeys.transaction_liability_name_suggestions_personal,
    'd2': PrjLocaleKeys.transaction_liability_name_suggestions_bank,
    'd3': PrjLocaleKeys.transaction_liability_name_suggestions_mortgage,
    'd4': PrjLocaleKeys.transaction_liability_name_suggestions_credit_card,
    'd5': PrjLocaleKeys.transaction_liability_name_suggestions_installment,
    'd9': PrjLocaleKeys.transaction_liability_name_suggestions_other,
    // Lend
    'd6': PrjLocaleKeys.transaction_liability_name_suggestions_lend_personal,
    'd8': PrjLocaleKeys.transaction_liability_name_suggestions_lend_other,
  };

  /// The suggestions' translation key for [categoryId]; null when it has none.
  static String? keyFor(String? categoryId) => _keyByCategoryId[categoryId];
}
