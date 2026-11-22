import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/domain/entities/category_entity.dart';
import '../../../../core/domain/entities/liability_entity.dart';
import '../../../../core/quick_entry/quick_entry_intent.dart';
import 'transaction_controller.dart';
import 'transaction_form_controller.dart';

/// Moves quick-entry text typed on the wrong tab (e.g. "lend 500k" on the
/// expense tab) to the tab its intent belongs to.
abstract final class QuickEntryIntentRouter {
  /// Whether [intent] belongs to a different tab than [form].
  static bool belongsElsewhere(
    TransactionFormController form,
    QuickEntryIntent intent,
  ) => switch (intent) {
    QuickEntryIntent.expense =>
      form.quickEntryCategoryType != CategoryType.expense,
    QuickEntryIntent.income =>
      form.quickEntryCategoryType != CategoryType.income,
    QuickEntryIntent.investment =>
      form.quickEntryCategoryType != CategoryType.investment,
    QuickEntryIntent.debt =>
      form.quickEntryCategoryType != CategoryType.liability ||
          form.quickEntryDirection != LiabilityDirection.borrow,
    QuickEntryIntent.lend =>
      form.quickEntryCategoryType != CategoryType.liability ||
          form.quickEntryDirection != LiabilityDirection.lend,
  };

  /// When [intent] belongs to another tab: switches to it, hands [text] to
  /// that tab's form after the frame, runs [afterHandOff] on it, and returns
  /// true (the caller stops). Otherwise applies the intent to [from] (e.g. an
  /// Investment sub-mode) and returns false.
  static bool routeOrApply({
    required TransactionFormController from,
    required QuickEntryIntent intent,
    required String text,
    void Function(TransactionFormController target)? afterHandOff,
  }) {
    if (!belongsElsewhere(from, intent)) {
      from.applyQuickEntryIntent(intent, text);
      return false;
    }

    '[AI_PARSING] 🔄 Intent $intent belongs to another tab than '
            '${from.quickEntryCategoryType} | switching'
        .Log('QuickEntryIntentRouter');
    final tabs = Get.find<TransactionController>();
    tabs.switchToTabForIntent(intent);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Object? target = tabs.getQuickEntryControllerForIntent(intent);
      if (target is! TransactionFormController || identical(target, from)) {
        return;
      }
      '[AI_PARSING] 🤝 Handing text to ${target.runtimeType}'.Log(
        'QuickEntryIntentRouter',
      );
      target.applyQuickEntryIntent(intent, text);
      target.quickEntry.quickEntryController
        ..text = text
        ..selection = TextSelection.collapsed(offset: text.length);
      afterHandOff?.call(target);
    });
    return true;
  }
}
