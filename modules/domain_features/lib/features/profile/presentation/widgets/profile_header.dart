import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import 'profile_level_badge.dart';

class ProfileHeader extends StatelessWidget {
  final CcUserEntity? user;
  final String displayName;
  final int level;
  final VoidCallback? onTap;
  final VoidCallback? onEditName;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.displayName,
    required this.level,
    this.onTap,
    this.onEditName,
  });

  @override
  Widget build(BuildContext context) {
    final rawSubtitle = user != null
        ? user!.displayIdentifier
        : el.tr(CcLocaleKeys.profile_not_logged_in);

    // If the display name is already the same as the identifier (common in
    // phone-only auth), hide the subtitle to avoid duplicate info.
    final subtitle = (user != null && displayName == rawSubtitle)
        ? ''
        : rawSubtitle;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                      : const CcIconToken(Icons.person_rounded, size: 30),
                ),
                const CcSpaceMD(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: CcText(
                              displayName,
                              textStyle: context.ccTextTheme.titleMedium
                                  ?.copyWith(
                                    color: context.ccColorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user != null && onEditName != null) ...[
                            const CcSpaceXS(),
                            GestureDetector(
                              onTap: onEditName,
                              child: Icon(
                                Icons.edit_rounded,
                                size: context.respIconSize(baseSize: 16),
                                color: context.ccColorScheme.onPrimary
                                    .withOpacity(0.85),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const CcSpaceXS(),
                        CcText(
                          subtitle,
                          textStyle: context.ccTextTheme.bodySmall?.copyWith(
                            color: context.ccColorScheme.onPrimary.withOpacity(
                              0.7,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ProfileLevelBadge('LV$level'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
