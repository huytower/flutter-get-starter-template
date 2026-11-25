import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../../../core/currency/money_formatter.dart';

/// The counted-amount field: the SDK [CcTextField] (same look as the other
/// pages) driven by the money keypad instead of the system keyboard, with the
/// localized "Actual" label as its hint.
class WalletActualBalanceInput extends StatefulWidget {
  /// Counted amount, or null while the wallet has not been counted yet.
  final int? actual;
  final bool hasEditing;
  final String currencyCode;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const WalletActualBalanceInput({
    super.key,
    required this.actual,
    required this.hasEditing,
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
              borderColor: widget.hasEditing
                  ? scheme.primary
                  : scheme.outline.withValues(alpha: 0.5),
              borderWidth: widget.hasEditing ? 1.5 : 1,
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
