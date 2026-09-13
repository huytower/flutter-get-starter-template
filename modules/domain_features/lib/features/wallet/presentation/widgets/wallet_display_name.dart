import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/cc_locale_keys.dart';

import '../../domain/entities/wallet_entity.dart';

extension WalletDisplayName on WalletEntity {
  String displayName(BuildContext context) {
    if (type == WalletType.cash) {
      return el.tr(CcLocaleKeys.wallet_cash);
    }
    // For bank, ewallet, and other wallet types, show the actual wallet name
    // Only cash wallet uses a fixed localized name
    return name;
  }
}
