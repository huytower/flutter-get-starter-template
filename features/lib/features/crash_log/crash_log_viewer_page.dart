import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// Bottom sheet that shows the on-device [catcher_2](https://pub.dev/packages/catcher_2) log file.
///
/// Open via long-press on the app root ([CrashLogDevOverlay]) in debug builds.
@immutable
class CrashLogViewerPage extends StatefulWidget {
  const CrashLogViewerPage({super.key});

  @override
  State<CrashLogViewerPage> createState() => _CrashLogViewerPageState();
}

class _CrashLogViewerPageState extends State<CrashLogViewerPage> {
  String _logContent = '';
  String _appInfo = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final version = await getIt<CcDeviceInfoHelper>().getAppVersion();
    final logs = await CcCrashLogPaths.readLogContent();
    if (!mounted) return;
    setState(() {
      _appInfo = '${CcAppTrackName.appName}/$version';
      _logContent = logs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CcSpaceSM(),
        Row(
          children: [
            Expanded(
              child: AppNameWidget(
                _appInfo,
                fontSize: CcTypographyParams.bodySmall,
              ),
            ),
            CcCopyBtn(onTap: () => CcStringHelper.copyToClipboard(_appInfo)),
          ],
        ),
        const CcSpaceSM(),
        CcDividerLine(color: context.ccColorScheme.outlineVariant),
        const CcSpaceSM(),
        CcText(
          'Long-press anywhere on the app to open this screen (debug).',
          color: context.ccColorScheme.onSurfaceVariant,
          fontSize: CcTypographyParams.labelSmall,
          textAlign: TextAlign.center,
          align: Alignment.center,
        ),
        const CcSpaceSM(),
        _buildLogBody(),
        const CcSpaceSM(),
        CcDividerLine(color: context.ccColorScheme.outlineVariant),
        const CcSpaceSM(),
        Row(
          children: [
            Expanded(
              child: CcText(
                CcCrashLogPaths.logFileName,
                color: context.ccColorScheme.onSurfaceVariant,
                fontSize: CcTypographyParams.labelSmall,
                textAlign: TextAlign.center,
                align: Alignment.center,
              ),
            ),
            CcCopyBtn(
              onTap: () =>
                  CcStringHelper.copyToClipboard(CcCrashLogPaths.logFileName),
            ),
          ],
        ),
        const CcSpaceFooter(),
      ],
    );
  }

  Widget _buildLogBody() {
    if (_loading) {
      return Padding(
        padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_XL)),
        child: const Center(child: CcLoadingIconWidget()),
      );
    }
    if (_logContent.trim().isEmpty) {
      return CcText(
        'No crash logs yet.\nTrigger an error or restart after a crash.',
        color: context.ccColorScheme.onSurfaceVariant,
        fontSize: CcTypographyParams.bodySmall,
        textAlign: TextAlign.center,
        align: Alignment.center,
      );
    }
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.sizeOf(context).height * 0.5,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.respPadding(CcPaddingParams.SPACE_MD),
            ),
            child: SelectableText(
              _logContent,
              style: context.ccTextTheme.labelSmall?.copyWith(
                height: 1.4,
                fontFamily: 'monospace',
                fontSize: context.respFontSize(CcTypographyParams.labelSmall),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CcCopyBtn(
              onTap: () => CcStringHelper.copyToClipboard(_logContent),
            ),
          ),
        ],
      ),
    );
  }
}
