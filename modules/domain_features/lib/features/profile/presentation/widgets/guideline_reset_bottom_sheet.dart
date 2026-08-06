import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class GuidelineResetBottomSheet extends StatelessWidget {
  const GuidelineResetBottomSheet({
    super.key,
    required this.desc,
    required this.count,
    required this.onConfirm,
  });

  final String desc;
  final int count;
  final VoidCallback onConfirm;

  static Future<bool?> show(
    BuildContext context, {
    required String desc,
    required int count,
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GuidelineResetBottomSheet(
        desc: desc,
        count: count,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [_buildHeader(context, scheme), _buildBody(context, scheme)],
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
        vertical: context.respPadding(CcPaddingParams.SPACE_LG),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.primaryContainer],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.respDim(24)),
          topRight: Radius.circular(context.respDim(24)),
        ),
      ),
      child: Row(
        children: [
          CcIconToken(
            Icons.play_circle_outline_rounded,
            size: context.respIconSize(baseSize: 20),
            color: scheme.onPrimary,
          ),
          const CcSpaceSM(),
          CcText(
            el.tr(CcLocaleKeys.profile_view_tutorial),
            maxLines: 1,
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              color: scheme.onPrimary,
              fontWeight: CcTypographyParams.semiBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme scheme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.respDim(24)),
          bottomRight: Radius.circular(context.respDim(24)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDescription(context, scheme),
          _buildActions(context, scheme),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context, ColorScheme scheme) {
    return CcSymmetricPadding(
      horizontal: CcPaddingParams.PAGE_MD,
      vertical: CcPaddingParams.SPACE_MD,
      child: CcText(
        desc,
        maxLines: 2,
        textStyle: context.ccTextTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          height: 1.4,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildActions(BuildContext context, ColorScheme scheme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.respPadding(CcPaddingParams.PAGE_MD),
        0,
        context.respPadding(CcPaddingParams.PAGE_MD),
        context.respPadding(CcPaddingParams.PAGE_XS),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: CcText(
              el.tr(CcLocaleKeys.guideline_reset_confirm_cancel),
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                color: scheme.primary,
                fontWeight: CcTypographyParams.semiBold,
              ),
            ),
          ),
          const CcSpaceSM(),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              onConfirm();
            },
            child: CcText(
              el.tr(CcLocaleKeys.guideline_reset_confirm_agree),
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                color: scheme.primary,
                fontWeight: CcTypographyParams.semiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
