import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../domain/entities/app_update_status_entity.dart';
import '../../domain/usecases/open_app_store_usecase.dart';

/// Full-screen, non-dismissible screen asking the user to install the
/// required update. Back gestures are swallowed; the only way forward is the
/// store, and the screen stays until the app is relaunched after updating.
class ForceUpdatePage extends StatefulWidget {
  const ForceUpdatePage({super.key, required this.status});

  final AppUpdateRequired status;

  @override
  State<ForceUpdatePage> createState() => _ForceUpdatePageState();
}

class _ForceUpdatePageState extends State<ForceUpdatePage> {
  bool _isOpening = false;

  Future<void> _openStore() async {
    setState(() => _isOpening = true);
    final result = await getIt<OpenAppStoreUseCase>()();
    if (!mounted) return;
    setState(() => _isOpening = false);
    result.whenError((_) {
      CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: el.tr(CcLocaleKeys.app_update_open_store_failed),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.ccColorScheme.surface,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: EdgeInsets.all(
                context.respPadding(CcPaddingParams.DIALOG_LG),
              ),
              child: ConstrainedBox(
                // Centred vertically when it fits, scrollable when it doesn't
                // (phone landscape, large text).
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight -
                      2 * context.respPadding(CcPaddingParams.DIALOG_LG),
                ),
                child: CcMaxWidth.content(child: _buildContent(context)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final colors = context.ccColorScheme;
    final textTheme = context.ccTextTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIcon(context),
        const CcSpaceXL(),
        Text(
          el.tr(CcLocaleKeys.app_update_title),
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            color: colors.onSurface,
            fontWeight: CcTypographyParams.bold,
          ),
        ),
        const CcSpaceMD(),
        Text(
          el.tr(
            CcLocaleKeys.app_update_message,
            namedArgs: {'version': widget.status.minimumVersion.toString()},
          ),
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
        ),
        const CcSpaceSM(),
        Text(
          el.tr(
            CcLocaleKeys.app_update_current_version,
            namedArgs: {'version': widget.status.currentVersion.toString()},
          ),
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const CcSpaceXL(),
        CcSaveButton(
          label: el.tr(CcLocaleKeys.app_update_update_now),
          isLoading: _isOpening,
          onPressed: _isOpening ? null : _openStore,
        ),
      ],
    );
  }

  Widget _buildIcon(BuildContext context) {
    final colors = context.ccColorScheme;
    return Container(
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.DIALOG_LG)),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.system_update_rounded,
        size: context.respIconSize(baseSize: 48),
        color: colors.onPrimaryContainer,
      ),
    );
  }
}
