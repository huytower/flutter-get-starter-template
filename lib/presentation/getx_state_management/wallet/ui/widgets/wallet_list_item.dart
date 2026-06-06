import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class WalletListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? balance;
  final bool isNegative;
  final VoidCallback onTap;

  const WalletListItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.balance,
    this.isNegative = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: context.respPadding(CcPaddingParams.SPACE_SM),
      ),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surface,
        borderRadius: CcWidgetHelper.getBorderRoundedMD(),
        boxShadow: CcWidgetHelper.getBoxShadows(context),
      ),
      child: CcInkWell(
        onTap: onTap,
        borderRadius: CcWidgetHelper.getBorderRoundedMD(),
        child: Padding(
          padding: EdgeInsets.all(
            context.respPadding(CcPaddingParams.SPACE_MD),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  context.respPadding(CcPaddingParams.SPACE_SM),
                ),
                decoration: BoxDecoration(
                  color: context.ccColorScheme.primaryContainer.withOpacity(
                    0.3,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: context.ccColorScheme.primary,
                  size: context.respIconSize(baseSize: 24),
                ),
              ),
              const CcSpaceMD(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CcText(
                      title,
                      textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      CcText(
                        subtitle!,
                        textStyle: context.ccTextTheme.bodySmall?.copyWith(
                          color: context.ccColorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (balance != null)
                CcText(
                  balance!,
                  textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                    color: isNegative ? context.ccColorScheme.error : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const CcSpaceSM(),
              Icon(
                Icons.more_vert,
                color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.3),
                size: context.respIconSize(baseSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
