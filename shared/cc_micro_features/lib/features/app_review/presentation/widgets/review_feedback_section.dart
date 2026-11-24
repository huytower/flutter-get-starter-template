import 'package:cc_micro_features/l10n/cc_mf_locale_keys.dart';
import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

/// Feedback part of the review sheet: praise and criticism tags (two rows
/// each, scrolling sideways), a free-text field and a send button. Sends a
/// [CcFeedback] through [feedbackReporter] and closes the sheet.
class ReviewFeedbackSection extends StatefulWidget {
  const ReviewFeedbackSection({
    super.key,
    required this.feedbackReporter,
    required this.praiseOptions,
    required this.criticismOptions,
    this.rating,
  });

  final CcFeedbackReporter feedbackReporter;

  /// Already translated tags.
  final List<String> praiseOptions;
  final List<String> criticismOptions;

  /// Rating sent with the feedback.
  final double? rating;

  @override
  State<ReviewFeedbackSection> createState() => _ReviewFeedbackSectionState();
}

class _ReviewFeedbackSectionState extends State<ReviewFeedbackSection> {
  final TextEditingController _feedbackController = TextEditingController();
  final Set<String> _selected = <String>{};
  bool _hasSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _toggle(String option) {
    setState(() {
      if (!_selected.add(option)) _selected.remove(option);
    });
  }

  Future<void> _send(BuildContext context) async {
    if (_hasSubmitting) return;
    final text = _feedbackController.text.trim();

    if (_selected.isEmpty && text.isEmpty) {
      CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: el.tr(CcMfLocaleKeys.app_review_feedback_required),
      );
      return;
    }

    setState(() => _hasSubmitting = true);
    final praise = widget.praiseOptions.where(_selected.contains).toList();
    final criticism = widget.criticismOptions
        .where(_selected.contains)
        .toList();

    'User feedback: rating=${widget.rating}, praise=$praise, '
            'criticism=$criticism, text="$text"'
        .Log('ReviewFeedbackSection');

    try {
      await widget.feedbackReporter.send(
        CcFeedback(
          text: text,
          praise: praise,
          criticism: criticism,
          rating: widget.rating,
        ),
        labels: _reportLabels(),
      );
      if (!context.mounted) return;

      CcSnackBarHelper.showSuccessSnackBar(
        context: context,
        message: el.tr(CcMfLocaleKeys.app_review_feedback_sent),
      );
      _feedbackController.clear();
      setState(_selected.clear);
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _hasSubmitting = false);
    }
  }

  /// Captions of the message the team receives, in the user's language.
  CcFeedbackLabels _reportLabels() => CcFeedbackLabels(
    title: el.tr(CcMfLocaleKeys.app_review_report_title),
    rating: el.tr(CcMfLocaleKeys.app_review_report_rating),
    praise: el.tr(CcMfLocaleKeys.app_review_report_praise),
    criticism: el.tr(CcMfLocaleKeys.app_review_report_criticism),
    text: el.tr(CcMfLocaleKeys.app_review_report_text),
    none: el.tr(CcMfLocaleKeys.app_review_report_none),
    noText: el.tr(CcMfLocaleKeys.app_review_report_no_text),
    notRated: el.tr(CcMfLocaleKeys.app_review_report_not_rated),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.praiseOptions.isNotEmpty)
          _buildGroup(
            context,
            options: widget.praiseOptions,
            activeColor: scheme.primary,
            watermarkIcon: Icons.thumb_up_alt_rounded,
          ),
        if (widget.criticismOptions.isNotEmpty)
          _buildGroup(
            context,
            options: widget.criticismOptions,
            activeColor: scheme.error,
            watermarkIcon: Icons.thumb_down_alt_rounded,
          ),
        const CcSpaceSM(),
        CcPadding(
          CcTextField(
            controller: _feedbackController,
            hintText: el.tr(CcMfLocaleKeys.app_review_feedback_hint),
            maxLines: 3,
            height: context.respDim(80),
            textAlign: TextAlign.start,
            color: scheme.surfaceContainerHighest,
            borderColor: scheme.outlineVariant.withAlpha(10),
            borderWidth: 0.4,
          ),
          0,
          CcPaddingParams.PAGE_SM,
          CcPaddingParams.PAGE_SM,
          0,
        ),
        const CcSpaceSM(),
        CcPadding(
          CcSubmitButton(
            text: el.tr(CcMfLocaleKeys.app_review_feedback_send),
            hasSubmitting: _hasSubmitting,
            hasEnabled: !_hasSubmitting,
            activeColor: scheme.primary,
            onTap: () => _send(context),
            widthFactor: 1.0,
            leadingIcon: Icons.send_rounded,
          ),
          0,
          CcPaddingParams.PAGE_SM,
          CcPaddingParams.PAGE_SM,
          0,
        ),
      ],
    );
  }

  Widget _buildGroup(
    BuildContext context, {
    required List<String> options,
    required Color activeColor,
    required IconData watermarkIcon,
  }) {
    final half = (options.length / 2).ceil();
    return ClipRRect(
      borderRadius: BorderRadius.horizontal(left: context.brMd.topLeft),
      child: CcWatermarkBackground(
        icon: watermarkIcon,
        activeColor: activeColor,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.respDim(8)),
          child: CcHorizontalFadeScrollView(
            height: context.respDim(75),
            builder: (scrollController) => SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.respPadding(CcPaddingParams.SPACE_SM),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTagRow(options.sublist(0, half), activeColor),
                    const CcSpaceSM(),
                    _buildTagRow(options.sublist(half), activeColor),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagRow(List<String> options, Color activeColor) {
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const CcSpaceSM(),
          CcFeedbackTag(
            label: options[i],
            selected: _selected.contains(options[i]),
            activeColor: activeColor,
            onTap: () => _toggle(options[i]),
          ),
        ],
      ],
    );
  }
}
