import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../wallet/domain/entities/wallet_balance_entity.dart';

/// One wallet row in the reconciliation screen: shows the book balance and a
/// field for the user to enter the counted actual balance.
class WalletReconcileTile extends StatefulWidget {
  final WalletBalanceEntity balance;
  final ValueChanged<int> onActualChanged;

  const WalletReconcileTile({
    super.key,
    required this.balance,
    required this.onActualChanged,
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

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.respPadding(CcPaddingParams.SPACE_SM),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                if (diff != 0)
                  CcText(
                    el.tr(
                      diff > 0
                          ? CcLocaleKeys.reconciliation_surplus
                          : CcLocaleKeys.reconciliation_deficit,
                      namedArgs: {'amount': _money(diff.abs())},
                    ),
                    textStyle: context.ccTextTheme.bodySmall?.copyWith(
                      color: diff > 0 ? scheme.primary : scheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const CcSpaceMD(),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: el.tr(CcLocaleKeys.reconciliation_actual),
                suffixText: 'đ',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
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
    );
  }
}
