import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:message/export_message.dart';

/// Which name suggestions (`NameSuggestions`) the wallet sheets offer:
/// per wallet type in `AddLiquidSheet`, per investment category in
/// `AddInvestmentSheet`.
abstract final class WalletNameSuggestions {
  static const Map<String, String> _keyByType = {
    WalletType.bank: PrjLocaleKeys.wallet_name_suggestions_bank,
    WalletType.ewallet: PrjLocaleKeys.wallet_name_suggestions_ewallet,
    WalletType.emergencyFund:
        PrjLocaleKeys.wallet_name_suggestions_emergency_fund,
  };

  /// Investment category id (`CategorySeed`) → its suggestions' key.
  static const Map<String, String> _keyByInvestmentCategoryId = {
    'inv1': PrjLocaleKeys.wallet_investment_name_suggestions_stock,
    'inv2': PrjLocaleKeys.wallet_investment_name_suggestions_fund,
    'inv4': PrjLocaleKeys.wallet_investment_name_suggestions_term_deposit,
    'inv6': PrjLocaleKeys.wallet_investment_name_suggestions_real_estate,
    'inv5': PrjLocaleKeys.wallet_investment_name_suggestions_gold,
    'inv7': PrjLocaleKeys.wallet_investment_name_suggestions_crypto,
    'inv3': PrjLocaleKeys.wallet_investment_name_suggestions_bond,
    'inv8': PrjLocaleKeys.wallet_investment_name_suggestions_business,
  };

  /// The suggestions' translation key for a liquid wallet [type]; null when
  /// it has none (e.g. Cash).
  static String? keyForType(String? type) => _keyByType[type];

  /// The suggestions' translation key for an investment [categoryId]; null
  /// when it has none.
  static String? keyForInvestmentCategory(String? categoryId) =>
      _keyByInvestmentCategoryId[categoryId];
}
