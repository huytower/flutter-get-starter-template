import 'package:auto_route/annotations.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:data/domain/entities/comment/comment_entity.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

@RoutePage()
class CommentDetailPage extends StatelessWidget with CcViewConfigMixin {
  final CommentEntity comment;

  const CommentDetailPage({super.key, required this.comment});

  @override
  PreferredSizeWidget? appBar() {
    return AppBar(
      elevation: 0,
      leading: Builder(
        builder: (context) =>
            BackButton(color: context.ccColorScheme.onSurface),
      ),
      title: Builder(
        builder: (context) {
          return CcText(
            el.tr(CcLocaleKeys.comment_detail_title),
            align: Alignment.center,
            fontWeight: CcTypographyParams.bold,
            fontSize: CcTypographyParams.titleLarge,
            color: context.ccColorScheme.primary,
          );
        },
      ),
      centerTitle: true,
    );
  }

  @override
  Widget? buildContent() {
    return Builder(
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
            vertical: context.respPadding(CcPaddingParams.PAGE_LG),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const CcSpaceLG(),
              const CcDividerLine(),
              const CcSpaceLG(),
              _buildDescription(context),
              const CcSpaceXL(),
              _buildMetaData(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcText(
          comment.name,
          textStyle: context.ccTextTheme.headlineSmall?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: context.ccColorScheme.primary,
            fontSize: context.respFontSize(CcTypographyParams.headlineSmall),
          ),
        ),
        const CcSpaceSM(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.SPACE_MD),
            vertical: context.respPadding(CcPaddingParams.SPACE_XS),
          ),
          decoration: BoxDecoration(
            color: context.ccColorScheme.secondaryContainer,
            borderRadius: CcWidgetHelper.getBorderRoundedLG(),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.alternate_email,
                size: context.respIconSize(baseSize: 14),
                color: context.ccColorScheme.onSecondaryContainer,
              ),
              const CcSpaceXS(),
              CcText(
                comment.email,
                textStyle: context.ccTextTheme.labelMedium?.copyWith(
                  color: context.ccColorScheme.onSecondaryContainer,
                  fontWeight: CcTypographyParams.medium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: context.respDim(4),
              height: context.respDim(20),
              decoration: BoxDecoration(
                color: context.ccColorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const CcSpaceSM(),
            CcText(
              el.tr(CcLocaleKeys.comment_detail_content),
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                fontWeight: CcTypographyParams.bold,
              ),
            ),
          ],
        ),
        const CcSpaceSM(),
        CcText(
          comment.body,
          textStyle: context.ccTextTheme.bodyLarge?.copyWith(
            height: 1.6,
            color: context.ccColorScheme.onSurface,
            fontSize: context.respFontSize(CcTypographyParams.bodyLarge),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaData(BuildContext context) {
    return CcResponsiveFlex(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoChip(
          context,
          label: el.tr(CcLocaleKeys.comment_detail_post_id),
          value: '#${comment.postId}',
          icon: Icons.tag,
        ),
        _buildInfoChip(
          context,
          label: el.tr(CcLocaleKeys.comment_detail_id),
          value: '#${comment.id}',
          icon: Icons.numbers,
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.SPACE_MD),
        vertical: context.respPadding(CcPaddingParams.SPACE_SM),
      ),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: CcWidgetHelper.getBorderRoundedSM(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: context.ccColorScheme.primary),
          const CcSpaceXS(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CcText(
                label,
                textStyle: context.ccTextTheme.labelSmall?.copyWith(
                  color: context.ccColorScheme.onSurfaceVariant,
                ),
              ),
              CcText(
                value,
                textStyle: context.ccTextTheme.bodySmall?.copyWith(
                  fontWeight: CcTypographyParams.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
