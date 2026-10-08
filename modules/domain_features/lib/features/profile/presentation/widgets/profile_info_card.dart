import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/cc_locale_keys.dart';

import '../../../../core/di/di.dart';
import '../../../firestore/financial_data_sync_service.dart';
import '../../user_level/domain/entities/user_level_status_entity.dart';

class ProfileInfoCard extends StatelessWidget {
  final CcUserEntity? user;
  final int level;
  final int daysToNextAudit;
  final UserLevelStatusEntity levelStatus;
  final VoidCallback? onTap;
  final VoidCallback? onEditName;
  final VoidCallback? onLinkAccount;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onLinkPhone;
  final bool isImmersive;

  const ProfileInfoCard({
    super.key,
    required this.user,
    required this.level,
    required this.daysToNextAudit,
    required this.levelStatus,
    this.onTap,
    this.onEditName,
    this.onLinkAccount,
    this.onAvatarTap,
    this.onLinkPhone,
    this.isImmersive = false,
  });

  @override
  Widget build(BuildContext context) {
    final fullName = _getFullName();
    final email = user?.email ?? '';
    final phoneNumber = user?.phoneNumber ?? '';

    return CcBouncing(
      onTap: onTap,
      borderRadius: context.brLg,
      child: Container(
        width: double.infinity,
        decoration: isImmersive
            ? null
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.ccColorScheme.primary,
                    context.ccColorScheme.primaryContainer,
                  ],
                ),
                borderRadius: context.brLg,
                boxShadow: [
                  BoxShadow(
                    color: context.ccColorScheme.primary.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
        child: CcSymmetricPadding(
          horizontal: CcPaddingParams.PAGE_SM,
          vertical: CcPaddingParams.SPACE_SM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildUserInfoRow(context, fullName, email, phoneNumber),
              const CcSpaceXS(),
              _buildStatsRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Row buildUserInfoRow(
    BuildContext context,
    String fullName,
    String email,
    String phoneNumber,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Round corner box icon with Level Badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            buildUserAvatar(context),
            Positioned(
              right: context.respDim(-10),
              bottom: context.respDim(-10),
              child: _buildLevelBadge(context),
            ),
          ],
        ),
        const CcSpaceMD(),
        buildUserInfo(context, fullName, email, phoneNumber),
      ],
    );
  }

  CcBouncing buildUserAvatar(BuildContext context) {
    return CcBouncing(
      onTap: onAvatarTap,
      borderRadius: BorderRadius.circular(context.respDim(12)),
      child: Container(
        width: context.respDim(56),
        height: context.respDim(56),
        decoration: BoxDecoration(
          color: context.ccColorScheme.onPrimary,
          borderRadius: BorderRadius.circular(context.respDim(12)),
        ),
        child: user?.avatarUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(context.respDim(12)),
                child: Image.network(
                  user!.avatarUrl!,
                  width: context.respDim(56),
                  height: context.respDim(56),
                  fit: BoxFit.cover,
                ),
              )
            : Center(
                child: CcIconToken(
                  Icons.person_rounded,
                  size: 30,
                  color: context.ccColorScheme.primary,
                ),
              ),
      ),
    );
  }

  Column buildUserInfo(
    BuildContext context,
    String fullName,
    String email,
    String phoneNumber,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Full Name row with Edit icon
        _buildFullNameRow(context, fullName: fullName, onEdit: onEditName),
        const CcSpaceXS(),
        // Only show one authentication method: prioritize Email, then Phone.
        // If neither exists (Guest), show both as link targets.
        if (email.isNotEmpty)
          _buildEmailRow(context, email: email, onLink: onLinkAccount)
        else if (phoneNumber.isNotEmpty)
          _buildPhoneNumberRow(
            context,
            phoneNumber: phoneNumber,
            onLink: onLinkPhone,
          )
        else ...[
          _buildEmailRow(context, email: email, onLink: onLinkAccount),
          const CcSpaceXS(),
          _buildPhoneNumberRow(
            context,
            phoneNumber: phoneNumber,
            onLink: onLinkPhone,
          ),
        ],
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        buildAuditDay(context),
        const CcSpaceXS(),
        _buildSyncStatusIcon(context),
      ],
    );
  }

  Container buildAuditDay(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.SPACE_XS),
        vertical: context.respPadding(2),
      ),
      decoration: BoxDecoration(
        color: context.ccColorScheme.onPrimary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(context.respDim(6)),
      ),
      child: _buildAuditDayCell(
        context,
        icon: Icons.access_time_rounded,
        label: el.tr(CcLocaleKeys.profile_weekly_audit),
        value: el.tr(
          CcLocaleKeys.profile_days_left,
          namedArgs: {'count': '$daysToNextAudit'},
        ),
        valueColor: context.ccColorScheme.onPrimary,
      ),
    );
  }

  /// Sync indicator, resolved in strict priority order.
  ///
  /// Syncing is checked before pending on purpose: mid-merge the user is
  /// actively being rescued, and showing "N items not backed up — tap to
  /// sync" while the sync is already running invites a redundant tap.
  Widget _buildSyncStatusIcon(BuildContext context) {
    return Obx(() {
      final service = getIt<FinancialDataSyncService>();
      final online = service.isOnline.value;
      final syncing = service.isSyncing.value;
      final pending = service.pendingCount.value;

      final iconColor = context.ccColorScheme.onPrimary.withOpacity(0.8);
      final iconSize = context.respIconSize(baseSize: 20);

      late final Widget indicator;
      late final String tooltip;
      late final bool flagged;
      late final bool tappable;

      if (!online) {
        indicator = Icon(
          Icons.cloud_off_rounded,
          size: iconSize,
          color: iconColor,
        );
        tooltip = el.tr(CcLocaleKeys.sync_offline_tooltip);
        flagged = true;
        tappable = false;
      } else if (syncing) {
        indicator = SizedBox(
          width: iconSize,
          height: iconSize,
          child: CircularProgressIndicator(
            strokeWidth: context.respDim(2),
            valueColor: AlwaysStoppedAnimation<Color>(iconColor),
          ),
        );
        tooltip = el.tr(CcLocaleKeys.sync_syncing_tooltip);
        // Not an error and not actionable while the sync is in flight.
        flagged = false;
        tappable = false;
      } else if (pending > 0) {
        indicator = Icon(
          Icons.cloud_sync_rounded,
          size: iconSize,
          color: iconColor,
        );
        tooltip = el.tr(
          CcLocaleKeys.sync_pending_tooltip,
          namedArgs: {'count': '$pending'},
        );
        flagged = true;
        tappable = true;
      } else {
        indicator = Icon(
          Icons.cloud_done_rounded,
          size: iconSize,
          color: iconColor,
        );
        tooltip = el.tr(CcLocaleKeys.sync_synced_tooltip);
        flagged = false;
        tappable = false;
      }

      return CcIconButton(
        // The base constructor (not `.bouncing`) because that factory demands
        // a non-null callback. A null `onTap` is what makes the non-actionable
        // states genuinely inert. `isEnable` is deliberately left at its
        // default: it dims to 50% opacity, which would under-emphasise the
        // healthy "synced" icon — the red badge already carries "needs
        // attention" and the spinner already carries "busy".
        onTap: tappable ? () => service.syncAll() : null,
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            indicator,
            if (flagged)
              Positioned(
                right: context.respDim(-2),
                top: context.respDim(-2),
                child: Container(
                  width: context.respDim(8),
                  height: context.respDim(8),
                  decoration: BoxDecoration(
                    color: context.ccColorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.ccColorScheme.surface,
                      width: context.respDim(1),
                    ),
                  ),
                ),
              ),
          ],
        ),
        tooltip: tooltip,
      );
    });
  }

  Widget _buildAuditDayCell(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    bool isLocked = false,
  }) {
    final iconColor = isLocked
        ? context.ccColorScheme.onPrimary.withOpacity(0.5)
        : context.ccColorScheme.onPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: context.respIconSize(baseSize: 14), color: iconColor),
        const CcSpaceXS(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CcText(
              value,
              textStyle: context.ccTextTheme.labelSmall?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            CcText(
              label,
              textStyle: context.ccTextTheme.labelSmall?.copyWith(
                color: context.ccColorScheme.onPrimary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelBadge(BuildContext context) {
    final isVip = levelStatus.isVip;
    final assetPath = isVip
        ? 'assets/icon/ic_yellow.webp'
        : 'assets/icon/ic_green.webp';

    return Image.asset(
      assetPath,
      width: context.respDim(32),
      height: context.respDim(32),
      fit: BoxFit.contain,
    );
  }

  String _getFullName() {
    if (user == null) return '';
    final parts = [
      user!.firstName,
      user!.lastName,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
    return parts;
  }

  Widget _buildFullNameRow(
    BuildContext context, {
    required String fullName,
    VoidCallback? onEdit,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcText(
          fullName.isEmpty
              ? el.tr(CcLocaleKeys.profile_display_name_hint)
              : fullName,
          textStyle: context.ccTextTheme.bodySmall?.copyWith(
            color: context.ccColorScheme.onPrimary.withOpacity(
              fullName.isEmpty ? 0.5 : 0.85,
            ),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const CcSpaceXS(),
        CcBouncing(
          onTap: onEdit,
          child: Icon(
            Icons.edit_rounded,
            size: context.respIconSize(baseSize: 20),
            color: context.ccColorScheme.onPrimary.withOpacity(0.85),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailRow(
    BuildContext context, {
    required String email,
    VoidCallback? onLink,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CcText(
          email.isEmpty ? el.tr(CcLocaleKeys.auth_email) : email,
          textStyle: context.ccTextTheme.bodySmall?.copyWith(
            color: context.ccColorScheme.onPrimary.withOpacity(
              email.isEmpty ? 0.5 : 0.85,
            ),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (onLink != null && email.isEmpty) ...[
          const CcSpaceXS(),
          CcBouncing(
            onTap: onLink,
            child: Icon(
              Icons.link_rounded,
              size: context.respIconSize(baseSize: 20),
              color: context.ccColorScheme.onPrimary.withOpacity(0.85),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhoneNumberRow(
    BuildContext context, {
    required String phoneNumber,
    VoidCallback? onLink,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CcText(
          phoneNumber.isEmpty
              ? el.tr(CcLocaleKeys.auth_phone_number)
              : phoneNumber,
          textStyle: context.ccTextTheme.bodySmall?.copyWith(
            color: context.ccColorScheme.onPrimary.withOpacity(
              phoneNumber.isEmpty ? 0.5 : 0.85,
            ),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (onLink != null && phoneNumber.isEmpty) ...[
          const CcSpaceXS(),
          CcBouncing(
            onTap: onLink,
            child: Icon(
              Icons.link_rounded,
              size: context.respIconSize(baseSize: 20),
              color: context.ccColorScheme.onPrimary.withOpacity(0.85),
            ),
          ),
        ],
      ],
    );
  }
}
