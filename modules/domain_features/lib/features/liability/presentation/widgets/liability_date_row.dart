import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

/// A `dd/MM/yyyy`-formatted date as [CcText], optionally prefixed with an
/// icon — the recurring "due date" / "transaction date" row used across the
/// loan feature's list and detail widgets.
class LiabilityDateRow extends StatelessWidget {
  final DateTime? date;
  final String emptyText;
  final IconData? icon;
  final double iconSize;
  final Color? iconColor;
  final TextStyle? textStyle;

  const LiabilityDateRow({
    super.key,
    required this.date,
    this.emptyText = '—',
    this.icon,
    this.iconSize = 16,
    this.iconColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final date = this.date;
    final text = CcText(
      date != null ? el.DateFormat('dd/MM/yyyy').format(date) : emptyText,
      textStyle: textStyle ?? context.ccTextTheme.bodyMedium,
    );

    final icon = this.icon;
    if (icon == null) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: context.respIconSize(baseSize: iconSize),
          color: iconColor,
        ),
        const CcSpaceXS(),
        text,
      ],
    );
  }
}

