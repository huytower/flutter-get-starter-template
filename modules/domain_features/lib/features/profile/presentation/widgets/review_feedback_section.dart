import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:cc_sdk_ui/widgets/background/cc_watermark_background.dart';
import 'package:cc_sdk_ui/widgets/chip/cc_feedback_tag.dart';
import 'package:domain_features/features/transaction/presentation/widgets/transaction_submit_button.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGroup(
          context,
          keys: _praiseKeys,
          activeColor: context.ccColorScheme.primary,
          watermarkIcon: Icons.thumb_up_alt_rounded,
        ),
        _buildGroup(
          context,
          keys: _criticismKeys,
          activeColor: context.ccColorScheme.error,
          watermarkIcon: Icons.thumb_down_alt_rounded,
        ),
        const CcSpaceMD(),
        CcPadding(
          CcTextField(
            controller: _feedbackController,
            hintText: el.tr('profile.feedback_hint'),
            maxLines: 1,
            height: context.respDim(50),
            textAlign: TextAlign.start,
            color: context.ccColorScheme.surfaceContainerHighest,
            borderColor: context.ccColorScheme.outlineVariant.withAlpha(10),
            borderWidth: 0.4,
          ),
          0,
          CcPaddingParams.PAGE_SM,
          CcPaddingParams.PAGE_SM,
          0,
        ),
        TransactionSubmitButton(
          text: el.tr('profile.feedback_send'),
          isSubmitting: false,
          isEnabled: true,
          activeColor: context.ccColorScheme.primary,
          onTap: () => _send(context),
          widthFactor: 0.5,
          leadingIcon: Icons.send_rounded,
        ),
      ],
    );
  }

  Widget _buildGroup(
    BuildContext context, {
    required List<String> keys,
    required Color activeColor,
    required IconData watermarkIcon,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.horizontal(left: context.brMd.topLeft),
      child: CcWatermarkBackground(
        icon: watermarkIcon,
        activeColor: activeColor,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.respDim(8)),
          child: HorizontalFadeScrollView(
            height: context.respDim(75),
            builder: (scrollController) {
              final half = (keys.length / 2).ceil();
              final topKeys = keys.sublist(0, half);
              final bottomKeys = keys.sublist(half);

              return SingleChildScrollView(
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
                      Row(
                        children: [
                          for (var i = 0; i < topKeys.length; i++) ...[
                            CcFeedbackTag(
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
                            CcFeedbackTag(
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
