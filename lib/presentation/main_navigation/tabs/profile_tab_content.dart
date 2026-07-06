import 'package:catcher_2/catcher_2.dart';
import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:cc_micro_features/features/crash_log/export_crash_log.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class ProfileTabContent extends StatefulWidget {
  const ProfileTabContent({super.key});

  @override
  State<ProfileTabContent> createState() => _ProfileTabContentState();
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.ccColorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(context.respDim(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.respDim(12)),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.respDim(16),
            vertical: context.respDim(14),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: context.respIconSize(baseSize: 20),
                color: context.ccColorScheme.primary,
              ),
              SizedBox(width: context.respDim(12)),
              Expanded(
                child: CcText(
                  label,
                  textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.ccColorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: context.respIconSize(baseSize: 20),
                color: context.ccColorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTabContentState extends State<ProfileTabContent> {
  String _version = '';
  static const double _appBarHeight = kToolbarHeight + 16;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final version = await getIt<CcDeviceInfoHelper>().getAppVersion();
    if (mounted) {
      setState(() {
        _version = version;
      });
    }
  }

  void _openCategorySettings() {
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => const CategorySettingsPage(),
      ),
    );
  }

  void _openCrashLogViewer() {
    if (!CrashLogDevOverlay.isViewerEnabled) return;

    final navContext = Catcher2.navigatorKey.currentContext ?? context;
    CcDialogHelper.showModalBottomSheet(navContext, const CrashLogViewerPage());
  }

  @override
  Widget build(BuildContext context) {
    final appInfo = '${CcAppTrackName.appName} v$_version';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: _appBarHeight,
        centerTitle: true,
        title: CcText(
          el.tr(CcLocaleKeys.nav_profile),
          textStyle: context.ccTextTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.ccColorScheme.onSurface,
          ),
        ),
      ),
      body: StreamBuilder<CcUserEntity?>(
        stream: getIt<SessionContract>().userStream,
        builder: (context, snapshot) {
          final user = snapshot.data;

          return CcGradientCardLayout(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (user?.avatarUrl != null)
                  CircleAvatar(
                    radius: context.respDim(32),
                    backgroundImage: NetworkImage(user!.avatarUrl!),
                  )
                else
                  Icon(
                    Icons.person_rounded,
                    size: context.respIconSize(baseSize: 64.0),
                    color: context.ccColorScheme.primary,
                  ),
                const CcSpaceLG(),
                CcText(
                  user?.displayIdentifier ?? el.tr(CcLocaleKeys.nav_profile),
                  textStyle: context.ccTextTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: context.respFontSize(
                      CcTypographyParams.headlineSmall,
                    ),
                  ),
                  align: Alignment.center,
                ),
                if (user?.email != null)
                  CcText(
                    user!.email,
                    textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                      color: context.ccColorScheme.onSurfaceVariant,
                    ),
                  ),
                const CcSpaceXL(),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.respPadding(CcPaddingParams.SPACE_XL),
                  ),
                  child: _SettingsTile(
                    icon: Icons.tune_rounded,
                    label: el.tr(CcLocaleKeys.category_settings_title),
                    onTap: _openCategorySettings,
                  ),
                ),
                const CcSpaceMD(),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.respPadding(CcPaddingParams.SPACE_XL),
                  ),
                  child: CcBaseBtn(
                    onTap: () async {
                      await getIt<SessionContract>().clearSession();
                      if (context.mounted) {
                        getIt<AuthCoordinator>().navigateToLogin(context);
                      }
                    },
                    title: el.tr(CcLocaleKeys.auth_logout),
                    bgColor: [
                      context.ccColorScheme.error,
                      context.ccColorScheme.error.withOpacity(0.8),
                    ],
                  ),
                ),
                const CcSpaceXL(),
                // Hidden/Dev Trigger: Long press on App Name to open logs
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.respPadding(CcPaddingParams.SPACE_XL),
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onLongPress: _openCrashLogViewer,
                    child: AppNameWidget(
                      appInfo,
                      fontSize: CcTypographyParams.bodySmall,
                      color: context.ccColorScheme.onSurfaceVariant.withOpacity(
                        0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
