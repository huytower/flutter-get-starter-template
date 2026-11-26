import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/prj_locale_keys.dart';

import '../../../../core/budget/budget_name_helper.dart';

extension WalletDisplayName on WalletEntity {
  String displayName(BuildContext context) {
    // The built-in Cash wallet is stored with an empty name and labelled with
    // a localized string at display time.
    if (type == WalletType.cash) {
      return el.tr(PrjLocaleKeys.wallet_cash);
    }
    // A bank wallet the user named (including the default one, which can be
    // renamed) shows that name; only an unnamed one falls back to the label.
    if (type == WalletType.bank && name.trim().isEmpty) {
      return el.tr(PrjLocaleKeys.wallet_bank);
    }
    // For other wallets, use the name (including for investment wallets with categoryNameKey)
    return BudgetNameHelper.getDisplayName(
      name: name,
      categoryNameKey: categoryNameKey,
    );
  }
}
