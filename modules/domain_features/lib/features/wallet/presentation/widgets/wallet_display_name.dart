import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/cc_locale_keys.dart';

import '../../../../core/helper/budget_name_helper.dart';
import '../../domain/entities/wallet_entity.dart';

extension WalletDisplayName on WalletEntity {
  String displayName(BuildContext context) {
    if (name.isNotEmpty &&
        name != 'Tiền mặt' &&
        name != 'Ngân hàng' &&
        name != el.tr(CcLocaleKeys.wallet_cash) &&
        name != el.tr(CcLocaleKeys.wallet_bank)) {
      return name;
    }
    if (type == WalletType.cash) {
      return el.tr(CcLocaleKeys.wallet_cash);
    }
    if (type == WalletType.bank) {
      return el.tr(CcLocaleKeys.wallet_bank);
    }
    return BudgetNameHelper.getDisplayName(
      name: name,
      categoryNameKey: categoryNameKey,
    );
  }
}
