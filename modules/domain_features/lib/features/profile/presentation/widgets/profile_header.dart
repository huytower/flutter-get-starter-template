import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import 'profile_level_badge.dart';

class ProfileHeader extends StatelessWidget {
  final CcUserEntity? user;
  final String displayName;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = user != null
        ? user!.email
        : el.tr(CcLocaleKeys.profile_not_logged_in);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.ccColorScheme.primary,
            context.ccColorScheme.primaryContainer,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: CcSymmetricPadding(
          horizontal: CcPaddingParams.PAGE_SM,
          vertical: CcPaddingParams.SPACE_MD,
          child: Row(
            children: [
              CircleAvatar(
                radius: context.respDim(28),
                backgroundColor: context.ccColorScheme.onPrimary,
                child: user?.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          user!.avatarUrl!,
                          width: context.respDim(56),
                          height: context.respDim(56),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const CcIconToken(
                        Icons.person_rounded,
                        size: 30,
                      ),
              ),
              const CcSpaceMD(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CcText(
                      displayName,
                      textStyle: context.ccTextTheme.titleMedium?.copyWith(
                        color: context.ccColorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: context.respFontSize(
                          CcTypographyParams.titleMedium,
                        ),
                      ),
                    ),
                    const CcSpaceXS(),
                    CcText(
                      subtitle,
                      textStyle: context.ccTextTheme.bodySmall?.copyWith(
                        color: context.ccColorScheme.onPrimary.withOpacity(0.7),
                        fontSize: context.respFontSize(
                          CcTypographyParams.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const ProfileLevelBadge('LV1'),
            ],
          ),
        ),
      ),
    );
  }
}
