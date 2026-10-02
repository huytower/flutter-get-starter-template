import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/helper/ai_advice_helper.dart';
import '../../../../core/helper/ai_advice_highlight_helper.dart';
import '../../domain/entities/ai_advice_entity.dart';
import '../get_x/report_controller.dart';

class AiAdviceSection extends StatelessWidget {
  final ReportController controller;

  const AiAdviceSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.userLevel.status.value.isVip) {
        return const SizedBox.shrink();
      }

      final advice = controller.aiAdvice.value;
      final isGenerating = controller.isGeneratingAdvice.value;
      final errorKey = controller.aiAdviceErrorKey.value;

      return Container(
        padding: EdgeInsets.all(context.respDim(12)),
        decoration: BoxDecoration(
          color: PrjColors.info.withOpacity(0.1),
          borderRadius: context.brLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleRow(context, advice, isGenerating),
            const CcSpaceSM(),
            if (isGenerating)
              _buildLoadingBody(context)
            else if (advice != null)
              _buildAdviceBody(context, advice)
            else
              _buildEmptyBody(context),
            if (errorKey != null) ...[
              const CcSpaceXS(),
              CcText(
                el.tr(errorKey),
                textStyle: context.ccTextTheme.bodySmall?.copyWith(
                  color: context.ccColorScheme.error,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildTitleRow(
    BuildContext context,
    AiAdviceEntity? advice,
    bool isGenerating,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: context.respIconSize(baseSize: 16),
              color: PrjColors.info,
            ),
            const CcSpaceXS(),
            CcText(
              el.tr(CcLocaleKeys.report_ai_advice_title),
              textStyle: context.ccTextTheme.titleSmall?.copyWith(
                fontWeight: CcTypographyParams.bold,
                color: PrjColors.info,
              ),
            ),
          ],
        ),
        if (advice != null && !isGenerating)
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: context.respIconSize(baseSize: 20),
              color: context.ccColorScheme.onSurfaceVariant,
            ),
            onPressed: () => controller.generateAiAdvice(context),
          ),
      ],
    );
  }

  Widget _buildEmptyBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcText(
          el.tr(CcLocaleKeys.report_ai_advice_empty_body),
          textStyle: context.ccTextTheme.bodySmall?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant,
          ),
        ),
        const CcSpaceSM(),
        ElevatedButton.icon(
          onPressed: () => controller.generateAiAdvice(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.ccColorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(
            Icons.auto_awesome,
            size: context.respIconSize(baseSize: 16),
            color: context.ccColorScheme.onPrimary,
          ),
          label: CcText(
            el.tr(CcLocaleKeys.report_ai_advice_generate_cta),
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              color: context.ccColorScheme.onPrimary,
              fontWeight: CcTypographyParams.semiBold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingBody(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: context.respDim(16),
          height: context.respDim(16),
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(PrjColors.info),
          ),
        ),
        const CcSpaceXS(),
        CcText(
          el.tr(CcLocaleKeys.report_ai_advice_loading),
          textStyle: context.ccTextTheme.bodySmall?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAdviceBody(BuildContext context, AiAdviceEntity advice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in advice.sections) ...[
          _buildSectionCard(context, section),
          const CcSpaceXS(),
        ],
        CcText(
          _generatedAtLabel(advice.generatedAt),
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(BuildContext context, AiAdviceSectionItem section) {
    final color = _statusColor(context, section.status);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.respDim(10)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: context.brMd,
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _statusIcon(section.status),
            size: context.respIconSize(baseSize: 16),
            color: color,
          ),
          const CcSpaceXS(),
          Expanded(child: _buildSectionText(context, section, color)),
        ],
      ),
    );
  }

  Widget _buildSectionText(
    BuildContext context,
    AiAdviceSectionItem section,
    Color color,
  ) {
    final baseStyle = context.ccTextTheme.bodySmall?.copyWith(
      color: context.ccColorScheme.onSurface,
    );
    final highlightStyle = baseStyle?.copyWith(
      color: color,
      fontWeight: CcTypographyParams.bold,
    );

    return CcTextSpans([
      for (final segment in splitAiAdviceHighlights(
        section.text,
        section.highlights,
      ))
        TextSpan(
          text: segment.text,
          style: segment.isHighlighted ? highlightStyle : baseStyle,
        ),
    ]);
  }

  Color _statusColor(BuildContext context, AiAdviceSectionStatus status) {
    switch (status) {
      case AiAdviceSectionStatus.good:
        return PrjColors.success;
      case AiAdviceSectionStatus.normal:
        return PrjColors.info;
      case AiAdviceSectionStatus.bad:
        return context.ccColorScheme.error;
    }
  }

  IconData _statusIcon(AiAdviceSectionStatus status) {
    switch (status) {
      case AiAdviceSectionStatus.good:
        return Icons.check_circle_outline_rounded;
      case AiAdviceSectionStatus.normal:
        return Icons.info_outline_rounded;
      case AiAdviceSectionStatus.bad:
        return Icons.warning_amber_rounded;
    }
  }

  String _generatedAtLabel(DateTime generatedAt) {
    final elapsed = timeSinceGenerated(generatedAt);
    if (elapsed.inMinutes < 1) {
      return el.tr(CcLocaleKeys.report_ai_advice_generated_just_now);
    }
    if (elapsed.inHours < 1) {
      return el.tr(
        CcLocaleKeys.report_ai_advice_generated_minutes_ago,
        namedArgs: {'count': '${elapsed.inMinutes}'},
      );
    }
    if (elapsed.inDays < 1) {
      return el.tr(
        CcLocaleKeys.report_ai_advice_generated_hours_ago,
        namedArgs: {'count': '${elapsed.inHours}'},
      );
    }
    return el.tr(
      CcLocaleKeys.report_ai_advice_generated_days_ago,
      namedArgs: {'count': '${elapsed.inDays}'},
    );
  }
}
