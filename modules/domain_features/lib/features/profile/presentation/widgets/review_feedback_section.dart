import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
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
            height: context.respDim(128),
            textAlign: TextAlign.start,
            color: context.ccColorScheme.surfaceContainerHighest,
            borderColor: context.ccColorScheme.outlineVariant,
          ),
          const CcSpaceSM(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _send(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.ccColorScheme.primary,
                foregroundColor: context.ccColorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  vertical: context.respPadding(CcPaddingParams.SPACE_SM),
                ),
                shape: RoundedRectangleBorder(borderRadius: context.brMd),
              ),
              child: Text(el.tr('profile.feedback_send')),
            ),
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
        CcText(
          title,
          textStyle: context.ccTextTheme.titleSmall?.copyWith(
            color: context.ccColorScheme.onSurface,
            fontWeight: CcTypographyParams.bold,
          ),
        ),
        const CcSpaceXS(),
        Wrap(
          spacing: context.respDim(8),
          runSpacing: context.respDim(8),
          children: [
            for (final key in keys)
              _FeedbackTag(
                label: el.tr(key),
                selected: _selected.contains(key),
                activeColor: activeColor,
                onTap: () => _toggle(key),
              ),
          ],
        ),
      ],
    );
  }
}

class _FeedbackTag extends StatelessWidget {
  const _FeedbackTag({
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: context.brPill,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.SPACE_SM),
          vertical: context.respPadding(CcPaddingParams.SPACE_XS),
        ),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.18)
              : scheme.surfaceContainerHighest,
          borderRadius: context.brPill,
          border: Border.all(
            color: selected ? activeColor : scheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.respDim(170)),
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.ccTextTheme.bodySmall?.copyWith(
                  color: selected ? activeColor : scheme.onSurface,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            const CcSpaceXS(),
            Icon(
              selected ? Icons.close_rounded : Icons.add_rounded,
              size: context.respIconSize(baseSize: 16),
              color: selected ? activeColor : scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
