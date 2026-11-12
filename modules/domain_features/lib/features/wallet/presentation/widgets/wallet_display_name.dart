import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/cc_locale_keys.dart';

import '../../../../core/helper/budget_name_helper.dart';
import '../../domain/entities/wallet_entity.dart';

extension WalletDisplayName on WalletEntity {
  String displayName(BuildContext context) {
    // The built-in Cash wallet and the default Bank wallet are stored with an
    // empty name and labelled with a localized string at display time.
    if (type == WalletType.cash) {
      return el.tr(CcLocaleKeys.wallet_cash);
    }
    // A bank wallet the user created and named (e.g. "tcb777 99") must show
    // that name; only an unnamed one falls back to the localized label.
    if (type == WalletType.bank &&
        (id == 'wallet_bank' || name.trim().isEmpty)) {
      return el.tr(CcLocaleKeys.wallet_bank);
    }
    // For other wallets, use the name (including for investment wallets with categoryNameKey)
    return BudgetNameHelper.getDisplayName(
      name: name,
      categoryNameKey: categoryNameKey,
    );
  }
}
