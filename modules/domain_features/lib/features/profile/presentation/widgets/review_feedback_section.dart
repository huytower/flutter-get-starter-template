import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import 'reviews/feedback_tag.dart';

class ReviewFeedbackSection extends StatefulWidget {
  const ReviewFeedbackSection({super.key});

  @override
  State<ReviewFeedbackSection> createState() => _ReviewFeedbackSectionState();
}

class _ReviewFeedbackSectionState extends State<ReviewFeedbackSection> {
  final TextEditingController _feedbackController = TextEditingController();
  final Set<String> _selected = <String>{};

  static const _praiseKeys = [
    'profile.feedback_praise_fast',
    'profile.feedback_praise_offline',
    'profile.feedback_praise_runway',
    'profile.feedback_praise_reconciliation',
    'profile.feedback_praise_lending',
    'profile.feedback_praise_suggestions',
    'profile.feedback_praise_interface',
    'profile.feedback_praise_scanning',
    'profile.feedback_praise_alerts',
    'profile.feedback_praise_leveling',
  ];

  static const _criticismKeys = [
    'profile.feedback_criticism_sync',
    'profile.feedback_criticism_balance',
    'profile.feedback_criticism_unlock',
    'profile.feedback_criticism_scanning',
    'profile.feedback_criticism_amount',
    'profile.feedback_criticism_categories',
    'profile.feedback_criticism_limits',
    'profile.feedback_criticism_notifications',
    'profile.feedback_criticism_charts',
    'profile.feedback_criticism_speed',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _toggle(String key) {
    setState(() {
      if (!_selected.add(key)) _selected.remove(key);
    });
  }

  void _send(BuildContext context) {
    if (_selected.isEmpty && _feedbackController.text.trim().isEmpty) {
      CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: el.tr('profile.feedback_required'),
      );
      return;
    }
    CcSnackBarHelper.showSuccessSnackBar(
      context: context,
      message: el.tr('profile.feedback_sent'),
    );
    _feedbackController.clear();
    setState(() => _selected.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.respPadding(24),
        context.respPadding(8),
        context.respPadding(24),
        context.respPadding(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGroup(
            context,
            title: el.tr('profile.feedback_praise_title'),
            keys: _praiseKeys,
            activeColor: context.ccColorScheme.primary,
          ),
          const CcSpaceMD(),
          _buildGroup(
            context,
            title: el.tr('profile.feedback_criticism_title'),
            keys: _criticismKeys,
            activeColor: context.ccColorScheme.error,
          ),
          const CcSpaceMD(),
          CcTextField(
            controller: _feedbackController,
            hintText: el.tr('profile.feedback_hint'),
            maxLines: 5,
            height: context.respDim(90),
            textAlign: TextAlign.start,
            color: context.ccColorScheme.surfaceContainerHighest,
            borderColor: context.ccColorScheme.outlineVariant,
          ),
          const CcSpaceXS(),
          CcBaseBtn.bouncing(
            title: el.tr('profile.feedback_send'),
            onTap: () => _send(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(
    BuildContext context, {
    required String title,
    required List<String> keys,
    required Color activeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(text: title, color: context.ccColorScheme.onSurface),
        const CcSpaceXS(),
        HorizontalFadeScrollView(
          height: context.respDim(55),
          builder: (scrollController) {
            final half = (keys.length / 2).ceil();
            final topKeys = keys.sublist(0, half);
            final bottomKeys = keys.sublist(half);

            return SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < topKeys.length; i++) ...[
                        FeedbackTag(
                          label: el.tr(topKeys[i]),
                          selected: _selected.contains(topKeys[i]),
                          activeColor: activeColor,
                          onTap: () => _toggle(topKeys[i]),
                        ),
                        if (i < topKeys.length - 1) const CcSpaceSM(),
                      ],
                    ],
                  ),
                  const CcSpaceSM(),
                  Row(
                    children: [
                      for (var i = 0; i < bottomKeys.length; i++) ...[
                        FeedbackTag(
                          label: el.tr(bottomKeys[i]),
                          selected: _selected.contains(bottomKeys[i]),
                          activeColor: activeColor,
                          onTap: () => _toggle(bottomKeys[i]),
                        ),
                        if (i < bottomKeys.length - 1) const CcSpaceSM(),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
