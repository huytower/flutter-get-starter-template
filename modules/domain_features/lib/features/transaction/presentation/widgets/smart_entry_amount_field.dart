import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/helper/money_format_helper.dart';

class SmartEntryAmountField extends StatefulWidget {
  const SmartEntryAmountField({
    super.key,
    required this.amount,
    required this.currencyCode,
    required this.hasError,
    required this.onChanged,
  });

  final int amount;
  final String currencyCode;
  final bool hasError;
  final ValueChanged<int> onChanged;

  @override
  State<SmartEntryAmountField> createState() => _SmartEntryAmountFieldState();
}

class _SmartEntryAmountFieldState extends State<SmartEntryAmountField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.amount > 0 ? _group(widget.amount.toString()) : '',
  );

  String _group(String digits) =>
      MoneyFormatter.formatInput(digits, currencyCode: widget.currencyCode);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final textTheme = context.ccTextTheme;

    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        TextInputFormatter.withFunction((oldValue, newValue) {
          final grouped = _group(newValue.text);
          return TextEditingValue(
            text: grouped,
            selection: TextSelection.collapsed(offset: grouped.length),
          );
        }),
      ],
      onChanged: (value) => widget.onChanged(
        int.tryParse(value.replaceAll(RegExp(r'\D'), '')) ?? 0,
      ),
      style: textTheme.titleLarge?.copyWith(
        color: widget.hasError ? scheme.error : scheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        hintText: el.tr(CcLocaleKeys.transaction_amount),
        hintStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.3),
        ),
        suffixText: MoneyFormatter.getSymbol(widget.currencyCode),
        suffixStyle: textTheme.titleMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
