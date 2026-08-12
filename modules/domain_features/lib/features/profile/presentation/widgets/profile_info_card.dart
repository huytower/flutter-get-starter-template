import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../firestore/financial_data_sync_service.dart';
import '../../../user_level/domain/entities/user_level_status_entity.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final fullName = _getFullName();
    final email = user?.email ?? '';
    final phoneNumber = user?.phoneNumber ?? '';

    return CcInkWell(
      onTap: onTap,
      borderRadius: context.brLg,
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
          borderRadius: context.brLg,
          boxShadow: [
            BoxShadow(
              color: context.ccColorScheme.primary.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: CcSymmetricPadding(
            horizontal: CcPaddingParams.PAGE_SM,
            vertical: CcPaddingParams.SPACE_MD,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildUserInfoRow(context, fullName, email, phoneNumber),
                const CcSpaceXS(),
                _buildStatsRow(context),
              ],
            ),
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
        buildUserAvatar(context),
        const CcSpaceMD(),
        buildUserInfo(context, fullName, email, phoneNumber),
      ],
    );
  }

  CcInkWell buildUserAvatar(BuildContext context) {
    return CcInkWell(
      onTap: onAvatarTap,
      borderRadius: BorderRadius.circular(context.respDim(12)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
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
          Positioned(
            right: context.respDim(-4),
            bottom: context.respDim(-4),
            child: _buildLevelBadge(context),
          ),
        ],
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
        // Email row with Linking icon
        _buildEmailRow(context, email: email, onLink: onLinkAccount),
        const CcSpaceXS(),
        // Phone Number row (value only)
        _buildPhoneNumberRow(
          context,
          phoneNumber: phoneNumber,
          onLink: onLinkPhone,
        ),
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

  Widget _buildSyncStatusIcon(BuildContext context) {
    return Obx(() {
      final service = getIt<FinancialDataSyncService>();
      final online = service.isOnline.value;
      final pending = service.pendingCount.value;
      final flagged = !online || pending > 0;

      final icon = !online
          ? Icons.cloud_off_rounded
          : pending > 0
          ? Icons.cloud_sync_rounded
          : Icons.cloud_done_rounded;

      final tooltip = !online
          ? el.tr(CcLocaleKeys.sync_offline_tooltip)
          : pending > 0
          ? el.tr(
              CcLocaleKeys.sync_pending_tooltip,
              namedArgs: {'count': '$pending'},
            )
          : el.tr(CcLocaleKeys.sync_synced_tooltip);

      return CcIconButton.bouncing(
        onTap: online ? () => service.syncAll() : () {},
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              size: context.respIconSize(baseSize: 20),
              color: context.ccColorScheme.onPrimary.withOpacity(0.8),
            ),
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.SPACE_XS),
        vertical: context.respPadding(2),
      ),
      decoration: BoxDecoration(
        color: context.ccColorScheme.secondary,
        borderRadius: BorderRadius.circular(context.respDim(4)),
        border: Border.all(
          color: context.ccColorScheme.onPrimary,
          width: context.respDim(1.5),
        ),
      ),
      child: CcText(
        'LV$level',
        textStyle: context.ccTextTheme.labelSmall?.copyWith(
          color: context.ccColorScheme.onSecondary,
          fontWeight: FontWeight.bold,
          fontSize: context.respFontSize(10),
        ),
      ),
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
        CcInkWell(
          onTap: onEdit,
          child: Icon(
            Icons.edit_rounded,
            size: context.respIconSize(baseSize: 14),
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
        const CcSpaceXS(),
        CcInkWell(
          onTap: onLink,
          child: Icon(
            Icons.link_rounded,
            size: context.respIconSize(baseSize: 14),
            color: context.ccColorScheme.onPrimary.withOpacity(0.85),
          ),
        ),
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
        if (onLink != null) ...[
          const CcSpaceXS(),
          CcInkWell(
            onTap: onLink,
            child: Icon(
              Icons.link_rounded,
              size: context.respIconSize(baseSize: 14),
              color: context.ccColorScheme.onPrimary.withOpacity(0.85),
            ),
          ),
        ],
      ],
    );
  }
}
