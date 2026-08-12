import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:multiple_result/multiple_result.dart';

class ProfileDeleteConfirmSheet extends StatefulWidget {
  const ProfileDeleteConfirmSheet({super.key, required this.onConfirm});

  final Future<Result<Unit, CcFailure>> Function(BuildContext) onConfirm;

  @override
  State<ProfileDeleteConfirmSheet> createState() =>
      _ProfileDeleteConfirmSheetState();
}

class _ProfileDeleteConfirmSheetState extends State<ProfileDeleteConfirmSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_LG)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(context.respDim(14)),
                decoration: BoxDecoration(
                  color: scheme.error.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_remove_rounded,
                  color: scheme.error,
                  size: context.respIconSize(baseSize: 28),
                ),
              ),
            ),
            const CcSpaceMD(),
            CcText(
              el.tr(CcLocaleKeys.profile_delete_confirm),
              align: Alignment.center,
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const CcSpaceSM(),
            CcText(
              el.tr(CcLocaleKeys.profile_delete_confirm_desc),
              align: Alignment.center,
              maxLines: 5,
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const CcSpaceLG(),
            Row(
              children: [
                Expanded(
                  child: CcBaseBtn(
                    title: el.tr(CcLocaleKeys.common_cancel),
                    isEnable: !_isLoading,
                    bgColor: [
                      scheme.surfaceContainerHighest,
                      scheme.surfaceContainerHighest,
                    ],
                    textColor: scheme.onSurface,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const CcSpaceMD(),
                Expanded(
                  child: CcBaseBtn(
                    title: _isLoading
                        ? null
                        : el.tr(CcLocaleKeys.profile_delete_account),
                    isEnable: !_isLoading,
                    bgColor: [scheme.error, scheme.error],
                    textColor: scheme.onError,
                    onTap: () async {
                      setState(() => _isLoading = true);
                      try {
                        final result = await widget.onConfirm(context);
                        if (context.mounted) {
                          Navigator.of(context).pop(result);
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                  ),
                ),
              ],
            ),
            if (_isLoading) ...[
              const CcSpaceMD(),
              const Center(child: CcLoadingIconWidget()),
            ],
          ],
        ),
      ),
    );
  }
}
