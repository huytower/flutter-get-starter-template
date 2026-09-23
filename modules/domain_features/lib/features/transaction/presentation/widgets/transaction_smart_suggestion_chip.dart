import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/helper/money_format_helper.dart';
import '../../domain/entities/transaction_entity.dart';
import '../get_x/expense_form_controller.dart';

class TransactionSmartSuggestionChip extends StatelessWidget {
  const TransactionSmartSuggestionChip({
    super.key,
    required this.expenseFormController,
    required this.accentColor,
  });

  final ExpenseFormController expenseFormController;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final suggestionLabel = _suggestionLabel(expenseFormController);
    if (suggestionLabel == null) return const SizedBox.shrink();

    final icon = expenseFormController.merchantMatchSuggestion.value != null
        ? Icons.auto_awesome
        : expenseFormController.billMatchSuggestion.value != null
        ? Icons.event_repeat
        : Icons.place;

    return CcSuggestionChip(
      label: suggestionLabel,
      accentColor: accentColor,
      icon: icon,
      onTap: () => _applySuggestion(expenseFormController),
      onDismiss: () => _dismissSuggestion(expenseFormController),
    );
  }

  String? _suggestionLabel(ExpenseFormController controller) {
    final merchantMatch = controller.merchantMatchSuggestion.value;
    if (merchantMatch != null) {
      return el.tr(
        CcLocaleKeys.transaction_merchant_match_hint,
        namedArgs: {'label': _formatSuggestionLabel(merchantMatch)},
      );
    }
    final billMatch = controller.billMatchSuggestion.value;
    if (billMatch != null) {
      return el.tr(
        CcLocaleKeys.transaction_bill_match_hint,
        namedArgs: {'label': _formatSuggestionLabel(billMatch)},
      );
    }
    final locationMatch = controller.locationMatchSuggestion.value;
    if (locationMatch != null) {
      return el.tr(
        CcLocaleKeys.transaction_location_match_hint,
        namedArgs: {'label': _formatSuggestionLabel(locationMatch)},
      );
    }
    return null;
  }

  String _formatSuggestionLabel(TransactionEntity match) =>
      '${match.category} · ${formatVndShort(match.amount)}đ';

  void _applySuggestion(ExpenseFormController controller) {
    final merchantMatch = controller.merchantMatchSuggestion.value;
    if (merchantMatch != null) {
      controller.applyMerchantMatch(merchantMatch);
      return;
    }
    final billMatch = controller.billMatchSuggestion.value;
    if (billMatch != null) {
      controller.applyBillMatch(billMatch);
      return;
    }
    final locationMatch = controller.locationMatchSuggestion.value;
    if (locationMatch != null) controller.applyLocationMatch(locationMatch);
  }

  void _dismissSuggestion(ExpenseFormController controller) {
    if (controller.merchantMatchSuggestion.value != null) {
      controller.dismissMerchantMatch();
    } else if (controller.billMatchSuggestion.value != null) {
      controller.dismissBillMatch();
    } else {
      controller.dismissLocationMatch();
    }
  }
}
