import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../transaction/presentation/widgets/cc_form_label.dart';
import '../../domain/entities/loan_entity.dart';
import '../get_x/loan_form_controller.dart';

/// Counterparty name field on [LoanForm]: a free-text [CcTextField] for VIP
/// users, or a read-only hint (name fixed to the category label) for
/// free-tier users who haven't unlocked custom naming.
class LoanCounterpartyField extends StatelessWidget {
  final LoanFormController controller;
  final Color accentColor;

  const LoanCounterpartyField({
    super.key,
    required this.controller,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isBorrowSide = controller.direction.value == LoanDirection.borrow;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(
          text: isBorrowSide
              ? el.tr(CcLocaleKeys.transaction_loan_name_label)
              : el.tr(CcLocaleKeys.transaction_loan_borrower_label),
        ),
        const CcSpaceXS(),
        if (controller.isVip.value)
          CcTextField(
            controller: controller.counterpartyController,
            hintText: isBorrowSide
                ? el.tr(CcLocaleKeys.transaction_loan_name_hint)
                : el.tr(CcLocaleKeys.transaction_loan_borrower_hint),
            maxLines: 1,
            onChanged: controller.setCounterparty,
          )
        else
          _VipLockedCounterpartyHint(
            controller: controller,
            accentColor: accentColor,
          ),
      ],
    );
  }
}

/// Free-tier read-only substitute for the counterparty [CcTextField]: the
/// name is fixed to the category's own label — no text field to edit it.
class _VipLockedCounterpartyHint extends StatelessWidget {
  final LoanFormController controller;
  final Color accentColor;

  const _VipLockedCounterpartyHint({
    required this.controller,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(12),
        vertical: context.respPadding(10),
      ),
      decoration: BoxDecoration(
        color: context.ccColorScheme.onSurface.withAlpha(10),
        borderRadius: context.brMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: context.respIconSize(baseSize: 18),
            color: accentColor,
          ),
          const CcSpaceXS(),
          Expanded(
            child: CcText(
              el.tr(
                CcLocaleKeys.transaction_loan_counterparty_vip_locked,
                namedArgs: {'name': controller.counterpartyName.value},
              ),
              textStyle: context.ccTextTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
