import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/core/helper/budget_name_helper.dart';

/// How the wallet screens order and group wallets.
abstract final class WalletOrdering {
  /// Id of the built-in bank wallet, listed right after Cash.
  static const String defaultBankId = 'wallet_bank';

  static const List<String> _liquidTypeOrder = [
    WalletType.cash,
    WalletType.bank,
    WalletType.ewallet,
    WalletType.emergencyFund,
  ];

  /// Cash first, the default bank next, then by type and name.
  static List<WalletEntity> liquid(Iterable<WalletEntity> wallets) {
    final liquid = wallets
        .where((w) => _liquidTypeOrder.contains(w.type))
        .toList();
    liquid.sort((a, b) {
      if (a.type == WalletType.cash && b.type != WalletType.cash) return -1;
      if (b.type == WalletType.cash && a.type != WalletType.cash) return 1;
      if (_isDefaultBank(a) && b.type != WalletType.cash) return -1;
      if (_isDefaultBank(b) && a.type != WalletType.cash) return 1;

      final typeCompare = _liquidTypeOrder
          .indexOf(a.type)
          .compareTo(_liquidTypeOrder.indexOf(b.type));
      if (typeCompare != 0) return typeCompare;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return liquid;
  }

  /// Liquid wallets with Cash first, otherwise in stored order.
  static List<WalletEntity> recentLiquid(Iterable<WalletEntity> wallets) {
    final liquid = wallets
        .where((w) => _liquidTypeOrder.contains(w.type))
        .toList();
    liquid.sort((a, b) {
      if (a.type == WalletType.cash) return -1;
      if (b.type == WalletType.cash) return 1;
      return 0;
    });
    return liquid;
  }

  /// Investment wallets by user order, then name; one per display name.
  static List<WalletEntity> investment(Iterable<WalletEntity> wallets) {
    final result = _uniqueInvestments(wallets)
      ..sort((a, b) {
        if (a.displayOrder != b.displayOrder) {
          return a.displayOrder.compareTo(b.displayOrder);
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return _dedupByDisplayName(result);
  }

  /// Investment wallets, most recently updated first; one per display name.
  static List<WalletEntity> recentInvestment(Iterable<WalletEntity> wallets) {
    final result = _uniqueInvestments(wallets)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return _dedupByDisplayName(result);
  }

  /// Cash and the default bank wallet cannot be deleted.
  static bool canDelete(WalletEntity wallet) =>
      wallet.type != WalletType.cash && !_isDefaultBank(wallet);

  static bool _isDefaultBank(WalletEntity w) =>
      w.type == WalletType.bank && w.id == defaultBankId;

  static List<WalletEntity> _uniqueInvestments(Iterable<WalletEntity> all) => {
    for (final w in all.where((w) => w.type == WalletType.investment)) w.id: w,
  }.values.toList();

  static List<WalletEntity> _dedupByDisplayName(List<WalletEntity> wallets) {
    final seen = <String, WalletEntity>{};
    for (final w in wallets) {
      final displayName = BudgetNameHelper.getDisplayName(
        name: w.name,
        categoryNameKey: w.categoryNameKey,
      );
      seen.putIfAbsent(displayName, () => w);
    }
    return seen.values.toList();
  }
}
