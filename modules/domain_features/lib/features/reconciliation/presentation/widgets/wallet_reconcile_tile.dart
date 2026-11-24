import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../../../../core/currency/money_formatter.dart';
import '../../../../core/di/di.dart';
import '../../../wallet/domain/entities/wallet_balance_entity.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../../../wallet/presentation/widgets/wallet_display_name.dart';
import '../get_x/reconciliation_controller.dart';

class WalletReconcileTile extends StatelessWidget {
  final WalletBalanceEntity balance;
  final ValueChanged<int> onActualChanged;
  final VoidCallback onAcknowledge;
  final VoidCallback onReview;

  const WalletReconcileTile({
    super.key,
    required this.balance,
    required this.onActualChanged,
    required this.onAcknowledge,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReconciliationController>();
    final walletController = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(getIt<WalletController>());

    final stacked = CcTwoColumn.shouldUse(context);

    return Obx(() {
      final currencyCode = walletController.currencyCode.value;
      final counted = controller.actualOf(balance.wallet.id);
      final isCounted = counted != null;
      final actual = counted ?? balance.bookBalance;
      final diff = actual - balance.bookBalance;
      final isBalanced = diff == 0;
      final isAcknowledged = controller.isAcknowledged(balance.wallet.id);
      final isResolved = isBalanced || isAcknowledged;
      final isEditing = controller.editingWalletId.value == balance.wallet.id;
      final scheme = context.ccColorScheme;

      Widget actualInput() => WalletActualBalanceInput(
        actual: counted,
        isEditing: isEditing,
        currencyCode: currencyCode,
        onTap: () => controller.startEditing(balance.wallet.id),
        onClear: () {
          if (isEditing) {
            controller.clearAmount();
          } else {
            controller.resetActual(balance.wallet.id);
          }
        },
      );

      // Not counted yet: neutral, never an error — the wallet is assumed to
      // match its book balance until the user enters a counted amount.
      final statusColor = !isCounted
          ? scheme.onSurfaceVariant
          : isResolved
          ? scheme.primary
          : scheme.error;

      return Container(
        margin: EdgeInsets.only(
          bottom: context.respDim(CcPaddingParams.SPACE_MD),
        ),
        padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_LG)),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: context.brLg,
          border: Border.all(
            color: isEditing
                ? scheme.primary
                : scheme.outlineVariant.withValues(alpha: 0.4),
            width: isEditing ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.10),
              blurRadius: context.respDim(12),
              offset: Offset(0, context.respDim(4)),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CcText(
                  balance.wallet.displayName(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                    fontWeight: CcTypographyParams.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const CcSpaceSM(),
                if (stacked) ...[
                  // Landscape tablet: two rows — "Book" + amount, then
                  // "Actual" + amount — so each amount has the full width.
                  _buildBookColumn(context, scheme, currencyCode),
                  const CcSpaceSM(),
                  actualInput(),
                ] else
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildBookColumn(
                            context,
                            scheme,
                            currencyCode,
                          ),
                        ),
                        VerticalDivider(
                          width: context.respDim(24),
                          thickness: 1,
                          color: scheme.outlineVariant.withValues(alpha: 0.6),
                        ),
                        Expanded(child: actualInput()),
                      ],
                    ),
                  ),
                const CcSpaceSM(),
                WalletReconcileStatusRow(
                  isCounted: isCounted,
                  isBalanced: isBalanced,
                  isAcknowledged: isAcknowledged,
                  diff: diff,
                  currencyCode: currencyCode,
                  statusColor: statusColor,
                  onAcknowledge: onAcknowledge,
                  onReview: onReview,
                  stacked: stacked,
                ),
              ],
            ),
            _buildGuidelineBadge(context),
          ],
        ),
      );
    });
  }

  /// Left half of the comparison row: the book balance.
  Widget _buildBookColumn(
    BuildContext context,
    ColorScheme scheme,
    String currencyCode,
  ) {
    return Row(
      children: [
        CcText(
          el.tr(PrjLocaleKeys.reconciliation_book),
          textStyle: context.ccTextTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const CcSpaceSM(),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: CcText(
              formatCurrencyWithSymbol(
                balance.bookBalance,
                currencyCode: currencyCode,
              ),
              maxLines: 1,
              textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                fontWeight: CcTypographyParams.bold,
                color: scheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuidelineBadge(BuildContext context) {
    return const SizedBox();
  }
}

/// The counted-amount field: the SDK [CcTextField] (same look as the other
/// pages) driven by the money keypad instead of the system keyboard, with the
/// localized "Actual" label as its hint.
class WalletActualBalanceInput extends StatefulWidget {
  /// Counted amount, or null while the wallet has not been counted yet.
  final int? actual;
  final bool isEditing;
  final String currencyCode;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const WalletActualBalanceInput({
    super.key,
    required this.actual,
    required this.isEditing,
    required this.currencyCode,
    required this.onTap,
    required this.onClear,
  });

  @override
  State<WalletActualBalanceInput> createState() =>
      _WalletActualBalanceInputState();
}

class _WalletActualBalanceInputState extends State<WalletActualBalanceInput> {
  final TextEditingController _controller = TextEditingController();

  String get _text => widget.actual == null
      ? ''
      : formatCurrencyWithSymbol(
          widget.actual!,
          currencyCode: widget.currencyCode,
        );

  @override
  void initState() {
    super.initState();
    _controller.text = _text;
  }

  @override
  void didUpdateWidget(covariant WalletActualBalanceInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != _text) _controller.text = _text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          // Absorb pointers so the field never takes focus / opens the system
          // keyboard; input comes from the money keypad.
          child: AbsorbPointer(
            child: CcTextField(
              controller: _controller,
              hintText: el.tr(PrjLocaleKeys.reconciliation_actual),
              margin: EdgeInsets.zero,
              textAlign: TextAlign.end,
              color: scheme.surface,
              borderColor: widget.isEditing
                  ? scheme.primary
                  : scheme.outline.withValues(alpha: 0.5),
              borderWidth: widget.isEditing ? 1.5 : 1,
              // Reserves room for the clear icon drawn on top.
              suffixIcon: widget.actual == null
                  ? null
                  : SizedBox(width: context.respDim(28)),
            ),
          ),
        ),
        // Outside the absorbed field so it stays tappable; the text is
        // right-aligned, so pad it clear of the icon.
        if (widget.actual != null)
          Padding(
            padding: EdgeInsets.only(
              right: context.respPadding(CcPaddingParams.SPACE_SM),
            ),
            child: CcBouncing(
              onTap: widget.onClear,
              child: Icon(
                Icons.cancel,
                size: context.respIconSize(baseSize: 16),
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
          ),
      ],
    );
  }
}

class WalletReconcileStatusRow extends StatelessWidget {
  final bool isCounted;
  final bool isBalanced;
  final bool isAcknowledged;
  final int diff;
  final String currencyCode;
  final Color statusColor;
  final VoidCallback onAcknowledge;
  final VoidCallback onReview;

  /// Puts the actions (create adjustment / review) on their own line, bottom
  /// right, so a large "Off by" amount never competes with them for width.
  final bool stacked;

  const WalletReconcileStatusRow({
    super.key,
    required this.isCounted,
    required this.isBalanced,
    required this.isAcknowledged,
    required this.diff,
    required this.currencyCode,
    required this.statusColor,
    required this.onAcknowledge,
    required this.onReview,
    this.stacked = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    if (!isCounted) {
      return Row(
        children: [
          Icon(
            Icons.radio_button_unchecked_rounded,
            size: context.respIconSize(baseSize: 16),
            color: scheme.onSurfaceVariant,
          ),
          const CcSpaceXS(),
          CcText(
            el.tr(PrjLocaleKeys.reconciliation_not_counted),
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    if (isBalanced) {
      return Row(
        children: [
          const CcIconToken(Icons.check_circle_outline, size: 16),
          const CcSpaceXS(),
          CcText(
            el.tr(PrjLocaleKeys.reconciliation_matched),
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final status = Row(
      children: [
        Icon(
          isAcknowledged ? Icons.check_circle_outline : Icons.error_outline,
          color: statusColor,
          size: 16,
        ),
        const CcSpaceXS(),
        CcText(
          el.tr(
            PrjLocaleKeys.reconciliation_lech,
            namedArgs: {
              'amount':
                  '${diff > 0 ? '+' : ''}${diff < 0 ? '-' : ''}${formatCurrencyWithSymbol(diff.abs(), currencyCode: currencyCode)}',
            },
          ),
          textStyle: context.ccTextTheme.bodySmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isAcknowledged)
          CcBouncing(
            onTap: onAcknowledge,
            child: CcText(
              el.tr(PrjLocaleKeys.reconciliation_create_adjustment),
              textStyle: context.ccTextTheme.bodySmall?.copyWith(
                color: scheme.error,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: scheme.error,
              ),
            ),
          )
        else
          CcText(
            el.tr(PrjLocaleKeys.common_done),
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        CcIconButton.bouncing(
          icon: Icon(
            Icons.fact_check_outlined,
            size: context.respIconSize(baseSize: 16),
            color: scheme.onSurfaceVariant,
          ),
          height: context.respDim(28),
          width: context.respDim(28),
          tooltip: el.tr(PrjLocaleKeys.reconciliation_review_transactions),
          onTap: onReview,
        ),
      ],
    );

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          status,
          const CcSpaceXS(),
          Align(alignment: Alignment.centerRight, child: actions),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [status, actions],
    );
  }
}
