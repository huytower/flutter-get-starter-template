import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class WalletSectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final bool isAction;

  const WalletSectionHeader({
    super.key,
    required this.title,
    this.count,
    this.isAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return CcSymmetricPadding(
      vertical: CcPaddingParams.SPACE_XS,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CcText(
            count != null ? '$title ($count)' : title,
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold
            ),
          ),
          Icon(
            isAction ? Icons.chevron_right : Icons.expand_more,
            color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.5),
            size: context.respIconSize(baseSize: 24),
          ),
        ],
      ),
    );
  }
}
