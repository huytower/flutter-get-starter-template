import 'dart:math';

import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:domain_features/features/guideline/guideline_controller.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../firestore/financial_data_sync_service.dart';
import '../get_x/profile_controller.dart';
import 'profile_experience_card.dart';
import 'profile_info_card.dart';

class ProfilePageHeader extends StatefulWidget {
  const ProfilePageHeader({super.key, required this.controller});

  final ProfileController controller;

  @override
  State<ProfilePageHeader> createState() => _ProfilePageHeaderState();
}

class _ProfilePageHeaderState extends State<ProfilePageHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late bool _isFrontVisible;

  @override
  void initState() {
    super.initState();
    _isFrontVisible = !widget.controller.settings.value.isHeaderFlipped;
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
      value: widget.controller.settings.value.isHeaderFlipped ? 1.0 : 0.0,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_flipController.isAnimating) return;

    if (_isFrontVisible) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() {
      _isFrontVisible = !_isFrontVisible;
    });
    widget.controller.setHeaderFlipped(!_isFrontVisible);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assetPath = isDark
        ? 'assets/bg/bg_header_dark.webp'
        : 'assets/bg/bg_header_light.webp';

    // Matches TransactionPage overlap logic.
    final overlap = context.respDim(64) / 2;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(context.respDim(16)),
            bottomRight: Radius.circular(context.respDim(16)),
          ),
          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.only(bottom: overlap),
          child: _buildHeroForeground(context),
        ),
      ),
    );
  }

  Widget _buildHeroForeground(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (MediaQuery.of(context).padding.top > 0)
          SizedBox(height: MediaQuery.of(context).padding.top),

        const CcSpaceMD(),
        CcSymmetricPadding(
          horizontal: CcPaddingParams.PAGE_MD,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeaderTitleSection(context),
              _buildHeaderActions(context),
            ],
          ),
        ),
        const CcSpaceSM(),
        _buildFlipContent(context),
        const CcSpaceSM(),
        CcSymmetricPadding(
          horizontal: CcPaddingParams.PAGE_MD,
          child: Obx(() => _buildBanner(context)),
        ),
      ],
    );
  }

  Widget _buildHeaderTitleSection(BuildContext context) {
    return Expanded(
      child: CcText(
        el.tr(CcLocaleKeys.nav_profile),
        textStyle: context.ccTextTheme.titleLarge?.copyWith(
          color: context.ccColorScheme.onPrimary,
          fontWeight: CcTypographyParams.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return _buildSyncStatusIcon(context);
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
              size: context.respIconSize(baseSize: 22),
              color: context.ccColorScheme.onPrimary.withValues(alpha: 0.9),
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

  Widget _buildFlipContent(BuildContext context) {
    final cardHeight = context.respDim(100);

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * pi;
        final isUnder = angle > pi / 2;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(angle),
          alignment: Alignment.center,
          child: isUnder
              ? Transform(
                  transform: Matrix4.identity()..rotateY(pi),
                  alignment: Alignment.center,
                  child: CcSymmetricPadding(
                    horizontal: CcPaddingParams.PAGE_MD,
                    child: ProfileExperienceCard(
                      level: widget.controller.userLevel.status.value.level,
                      levelStatus: widget.controller.userLevel.status.value,
                      onTap: _toggleFlip,
                      isImmersive: true,
                    ),
                  ),
                )
              : CcSymmetricPadding(
                  horizontal: CcPaddingParams.PAGE_MD,
                  child: ProfileInfoCard(
                    user: widget.controller.user.value,
                    level: widget.controller.userLevel.status.value.level,
                    daysToNextAudit: widget.controller.daysToNextAudit,
                    levelStatus: widget.controller.userLevel.status.value,
                    onTap: _toggleFlip,
                    onEditName: () =>
                        widget.controller.pickDisplayName(context),
                    onLinkAccount: () =>
                        widget.controller.handleLinkAccountTap(context),
                    onAvatarTap: () =>
                        widget.controller.handleAvatarTap(context),
                    onLinkPhone: () =>
                        widget.controller.handlePhoneLinkTap(context),
                    // Immersive mode: info card should be transparent/seamless
                    isImmersive: true,
                  ),
                ),
        );
      },
    );
  }

  Widget _buildBanner(BuildContext context) {
    final guideline = Get.find<GuidelineController>();
    final activeId = guideline.currentTaskId;
    final isGuidelineComplete = activeId == null;
    final accentColor = guideline.currentColor;

    // Specific tasks for Profile tab
    final bool isProfileTask =
        activeId == 'birth_year' || activeId == 'categories';

    if (isGuidelineComplete || !isProfileTask) {
      // If no guideline, show the reconciliation streak banner instead.
      return _buildReconciliationBanner(context);
    }

    // Otherwise show the guideline banner
    return GestureDetector(
      onTap: () => guideline.triggerBounce(),
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          guideline.isBannerHidden.value = true;
        }
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -300) {
          guideline.isBannerHidden.value = false;
        }
      },
      child: guideline.isBannerHidden.value
          ? const SizedBox.shrink()
          : CcListBannerSmall(
              title: guideline.bannerTitle,
              description: guideline.bannerDescription,
              accentColor: accentColor,
              onTap: () => guideline.triggerBounce(),
              icon: CcClipboardChecklistIcon(
                size: context.respDim(40) * 0.8,
                bodyColor: context.ccColorScheme.onPrimary.withValues(
                  alpha: 0.85,
                ),
                clipColor: context.ccColorScheme.onPrimary,
                markColor: accentColor,
              ),
            ),
    );
  }

  Widget _buildReconciliationBanner(BuildContext context) {
    final streak =
        widget.controller.userLevel.status.value.reconciliationStreak;
    final auditWeekday = widget.controller.weeklyAuditDayName;

    return CcListBannerSmall(
      title: el.tr(
        CcLocaleKeys.profile_reconciliation_streak_title,
        namedArgs: {'count': streak.toString()},
      ),
      description: el.tr(
        CcLocaleKeys.profile_reconciliation_streak_desc,
        namedArgs: {'day': auditWeekday},
      ),
      accentColor: context.ccColorScheme.secondary,
      icon: Icon(
        Icons.auto_awesome,
        color: context.ccColorScheme.onPrimary,
        size: context.respIconSize(baseSize: 20),
      ),
      onTap: () => widget.controller.userLevel.refresh(),
    );
  }
}
