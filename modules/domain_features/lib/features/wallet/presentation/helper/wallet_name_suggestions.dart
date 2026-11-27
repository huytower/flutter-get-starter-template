import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:message/export_message.dart';

/// Which name suggestions (`NameSuggestions`) `AddLiquidSheet` offers per
/// wallet type. Investment names are per region: `InvestmentNameCatalog`.
abstract final class WalletNameSuggestions {
  static const Map<String, String> _keyByType = {
    WalletType.bank: PrjLocaleKeys.wallet_name_suggestions_bank,
    WalletType.ewallet: PrjLocaleKeys.wallet_name_suggestions_ewallet,
    WalletType.emergencyFund:
        PrjLocaleKeys.wallet_name_suggestions_emergency_fund,
  };

  /// The suggestions' translation key for a liquid wallet [type]; null when
  /// it has none (e.g. Cash).
  static String? keyForType(String? type) => _keyByType[type];
}
