import 'package:catcher_2/catcher_2.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:features/features/crash_log/export_crash_log.dart';
import 'package:flutter/material.dart';

class ProfileTabContent extends StatefulWidget {
  const ProfileTabContent({super.key});

  @override
  State<ProfileTabContent> createState() => _ProfileTabContentState();
}

class _ProfileTabContentState extends State<ProfileTabContent> {
  String _version = '';

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

  void _openCrashLogViewer() {
    if (!CrashLogDevOverlay.isViewerEnabled) return;

    final navContext = Catcher2.navigatorKey.currentContext ?? context;
    CcDialogHelper.showModalBottomSheet(navContext, const CrashLogViewerPage());
  }

  @override
  Widget build(BuildContext context) {
    final appInfo = '${CcAppTrackName.appName} v$_version';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_rounded,
            size: context.respIconSize(baseSize: 64.0),
            color: context.ccColorScheme.primary,
          ),
          const CcSpaceLG(),
          CcText(
            el.tr(CcLocaleKeys.nav_profile),
            textStyle: context.ccTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: context.respFontSize(CcTypographyParams.headlineSmall),
            ),
            align: Alignment.center,
          ),
          const CcSpaceXL(),
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
                color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
