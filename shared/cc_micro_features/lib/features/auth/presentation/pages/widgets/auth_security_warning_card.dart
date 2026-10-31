import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

class AuthSecurityWarningCard extends StatelessWidget {
  const AuthSecurityWarningCard({super.key, required this.onOtherLoginTap});

  final VoidCallback onOtherLoginTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    final headerText = el.tr(CcLocaleKeys.auth_security_warning_title);
    final bullet1Text = el.tr(CcLocaleKeys.auth_security_warning_bullet_sms);
    final bullet2Text = el.tr(CcLocaleKeys.auth_security_warning_bullet_ai);
    final otherLoginText = el.tr(
      CcLocaleKeys.auth_security_warning_other_login,
    );

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: context.respDim(16)),
      padding: EdgeInsets.all(context.respDim(12)),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withAlpha(50),
        borderRadius: context.brLg,
        border: Border.all(
          color: scheme.outlineVariant.withAlpha(40),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.security_rounded,
                size: context.respIconSize(baseSize: 18),
                color: scheme.primary,
              ),
              const CcSpaceXS(),
              Expanded(
                child: CcText(
                  headerText,
                  maxLines: 3,
                  textStyle: context.ccTextTheme.labelMedium?.copyWith(
                    fontWeight: CcTypographyParams.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const CcSpaceSM(),
          _buildCheckItem(context, bullet1Text, scheme),
          const CcSpaceXS(),
          _buildCheckItem(context, bullet2Text, scheme),
          const CcSpaceMD(),
          CcBouncing(
            onTap: onOtherLoginTap,
            borderRadius: context.brMd,
            child: Container(
              width: double.infinity,
              height: context.respDim(40),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: context.brMd,
                border: Border.all(
                  color: scheme.primary.withAlpha(100),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.login_rounded,
                    size: context.respIconSize(baseSize: 16),
                    color: scheme.primary,
                  ),
                  const CcSpaceXS(),
                  CcText(
                    otherLoginText,
                    textStyle: context.ccTextTheme.labelMedium?.copyWith(
                      fontWeight: CcTypographyParams.bold,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(
    BuildContext context,
    String text,
    ColorScheme scheme,
  ) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: context.respIconSize(baseSize: 16),
          color: PrjColors.success,
        ),
        const CcSpaceXS(),
        Expanded(
          child: CcText(
            text,
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
