import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class WalletListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? balance;
  final bool isNegative;
  final VoidCallback onTap;
  final VoidCallback? onMore;

  const WalletListItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.balance,
    this.isNegative = false,
    required this.onTap,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final balanceText = balance ?? '';
    final isNegativeValue = balanceText.startsWith('-');

    return CcInkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
          vertical: context.respPadding(CcPaddingParams.SPACE_MD),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(
                context.respPadding(CcPaddingParams.SPACE_SM),
              ),
              decoration: BoxDecoration(
                color: context.ccColorScheme.primaryContainer.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.ccColorScheme.outlineVariant.withOpacity(0.2),
                ),
              ),
              child: Icon(
                icon,
                color: context.ccColorScheme.primary,
                size: context.respIconSize(baseSize: 28),
              ),
            ),
            const CcSpaceMD(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CcText(
                    title,
                  textStyle: context.ccTextTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.ccColorScheme.onSurface,
                  ),
                  ),
                  if (balance != null)
                    CcText(
                      balance!,
                      textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                        color: isNegativeValue
                            ? context.ccColorScheme.error
                            : context.ccColorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (onMore != null)
              InkWell(
                onTap: onMore,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(
                    context.respPadding(CcPaddingParams.SPACE_XS),
                  ),
                  child: Icon(
                    Icons.more_vert,
                    color: context.ccColorScheme.onSurfaceVariant,
                    size: context.respIconSize(baseSize: 20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
