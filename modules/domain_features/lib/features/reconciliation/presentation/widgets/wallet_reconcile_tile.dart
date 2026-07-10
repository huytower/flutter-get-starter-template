import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../wallet/domain/entities/wallet_balance_entity.dart';

class WalletReconcileTile extends StatefulWidget {
  final WalletBalanceEntity balance;
  final bool isAcknowledged;
  final ValueChanged<int> onActualChanged;
  final VoidCallback onAcknowledge;

  const WalletReconcileTile({
    super.key,
    required this.balance,
    required this.isAcknowledged,
    required this.onActualChanged,
    required this.onAcknowledge,
  });

  @override
  State<WalletReconcileTile> createState() => _WalletReconcileTileState();
}

class _WalletReconcileTileState extends State<WalletReconcileTile> {
  late final TextEditingController _controller;
  late int _actual;

  static String _money(int value) =>
      '${value.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")} đ';

  @override
  void initState() {
    super.initState();
    _actual = widget.balance.bookBalance;
    _controller = TextEditingController(
      text: widget.balance.bookBalance.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final diff = _actual - widget.balance.bookBalance;
    final isBalanced = diff == 0;
    final isResolved = isBalanced || widget.isAcknowledged;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isResolved
            ? scheme.primary.withValues(alpha: 0.06)
            : scheme.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: wallet name + book balance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CcText(
                widget.balance.wallet.name,
                textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              CcText(
                el.tr(
                  CcLocaleKeys.reconciliation_book_balance,
                  namedArgs: {'amount': _money(widget.balance.bookBalance)},
                ),
                textStyle: context.ccTextTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Row 2: "Thực tế" label + number input
          Row(
            children: [
              CcText(
                el.tr(CcLocaleKeys.reconciliation_actual),
                textStyle: context.ccTextTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: context.ccTextTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    suffixText: 'đ',
                    isDense: true,
                    filled: true,
                    fillColor: scheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: scheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: scheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: scheme.primary),
                    ),
                  ),
                  onChanged: (value) {
                    final parsed = int.tryParse(value.trim()) ??
                        widget.balance.bookBalance;
                    setState(() => _actual = parsed);
                    widget.onActualChanged(parsed);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Row 3: status
          if (isResolved)
            Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: scheme.primary, size: 16),
                const SizedBox(width: 4),
                CcText(
                  el.tr(CcLocaleKeys.reconciliation_matched),
                  textStyle: context.ccTextTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CcText(
                  el.tr(
                    CcLocaleKeys.reconciliation_lech,
                    namedArgs: {
                      'amount':
                          '${diff > 0 ? '+' : ''}${diff < 0 ? '-' : ''}${_money(diff.abs())}',
                    },
                  ),
                  textStyle: context.ccTextTheme.bodySmall?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: widget.onAcknowledge,
                  child: CcText(
                    el.tr(CcLocaleKeys.reconciliation_create_adjustment),
                    textStyle: context.ccTextTheme.bodySmall?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: scheme.error,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
