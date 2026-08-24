import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import 'cc_quick_amount_chips.dart';

/// A specialized input section for transaction amounts, featuring a display box
/// with a label prefix, formatted amount, action buttons, and quick-amount chips.
class CcAmountInputSection extends StatelessWidget {
  final String label;
  final String amountStr;
  final List<int> quickAmounts;
  final bool isKeypadVisible;
  final Color? activeColor;
  final VoidCallback onTap;
  final Function(int) onQuickAmountSelected;
  final VoidCallback? onClear;
  final VoidCallback? onCopy;
  final GlobalKey? fieldKey;

  const CcAmountInputSection({
    super.key,
    required this.label,
    required this.amountStr,
    required this.quickAmounts,
    required this.isKeypadVisible,
    required this.onTap,
    required this.onQuickAmountSelected,
    this.activeColor,
    this.onClear,
    this.onCopy,
    this.fieldKey,
  });

  Color _getAccent(BuildContext context) =>
      activeColor ?? context.ccColorScheme.error;

  String get _limitedAmountStr =>
      amountStr.length > 11 ? amountStr.substring(0, 11) : amountStr;

  @override
  Widget build(BuildContext context) {
    final accent = _getAccent(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputBox(context, accent),
        const CcSpaceSM(),
        _buildQuickChips(accent),
      ],
    );
  }

  Widget _buildInputBox(BuildContext context, Color accent) {
    return CcBouncing(
      key: fieldKey,
      onTap: onTap,
      borderRadius: context.brMd,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.SPACE_SM),
          vertical: context.respPadding(CcPaddingParams.SPACE_XS),
        ),
        height: context.respDim(45),
        decoration: BoxDecoration(
          color: context.ccColorScheme.surfaceVariant.withAlpha(80),
          borderRadius: context.brMd,
          border: Border.all(
            color: isKeypadVisible
                ? accent
                : context.ccColorScheme.outlineVariant.withAlpha(10),
            width: isKeypadVisible ? 1 : 0.4,
          ),
        ),
        child: Stack(
          children: [
            _buildLabelPrefix(context),
            _buildFormattedAmount(context, accent),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelPrefix(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: CcText(
        label,
        textStyle: context.ccTextTheme.labelSmall?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant.withAlpha(70),
        ),
      ),
    );
  }

  Widget _buildFormattedAmount(BuildContext context, Color accent) {
    return Align(
      alignment: Alignment.center,
      child: CcText(
        '${TransactionFormHelpers.formatAmount(_limitedAmountStr)} đ',
        align: Alignment.center,
        textAlign: TextAlign.center,
        textStyle: context.ccTextTheme.headlineMedium?.copyWith(
          fontWeight: CcTypographyParams.bold,
          color: accent,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (onCopy != null)
            CcIconButton.bouncing(
              width: context.respDim(20),
              height: context.respDim(20),
              icon: Icon(
                Icons.copy_rounded,
                color: context.ccColorScheme.onSurfaceVariant.withAlpha(80),
                size: context.respIconSize(baseSize: 14),
              ),
              onTap: onCopy!,
              tooltip: el.tr(CcLocaleKeys.common_copy),
            ),
          if (onClear != null)
            CcIconButton.bouncing(
              width: context.respDim(20),
              height: context.respDim(20),
              icon: Icon(
                Icons.close_rounded,
                color: context.ccColorScheme.onSurfaceVariant.withAlpha(80),
                size: context.respIconSize(baseSize: 14),
              ),
              onTap: onClear!,
              tooltip: el.tr(CcLocaleKeys.common_clear),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickChips(Color accent) {
    return CcQuickAmountChips(
      amounts: quickAmounts,
      onSelected: onQuickAmountSelected,
      activeColor: accent,
    );
  }
}
