import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_x/quick_entry_mixin.dart';
import '../get_x/transaction_controller.dart';
import 'transaction_auto_save_message.dart';
import 'transaction_wallet_summary.dart';

class TransactionHeaderTitle extends StatelessWidget {
  const TransactionHeaderTitle({
    super.key,
    required this.controller,
    this.quickEntryControllerFor,
  });

  final TransactionController controller;
  final QuickEntryMixin? Function(TransactionTabKind tab)?
  quickEntryControllerFor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final bool showSummary = controller.showWalletSummaryTemporarily.value;

        final tabs = controller.visibleTabs;
        final activeTab =
            tabs[controller.selectedTabIndex.value.clamp(0, tabs.length - 1)];
        final quickEntry = quickEntryControllerFor?.call(activeTab);
        final countdown = quickEntry?.autoSaveCountdown.value ?? 0;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: showSummary
              ? const TransactionWalletSummary(key: ValueKey('wallet_summary'))
              : (countdown > 0 && quickEntry != null
                    ? TransactionAutoSaveMessage(
                        countdown: countdown,
                        onCancel: quickEntry.cancelAutoSaveManually,
                      )
                    : _buildPageTitle(context)),
        );
      }),
    );
  }

  Widget _buildPageTitle(BuildContext context) {
    return CcText(
      el.tr(CcLocaleKeys.transaction_title),
      key: const ValueKey('transaction_title'),
      textStyle: context.ccTextTheme.titleLarge?.copyWith(
        color: context.ccColorScheme.onPrimary,
        fontWeight: CcTypographyParams.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
