import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/data/data_source/color/prj_color.dart';

import '../../../category/domain/entities/category_entity.dart';

class SmartEntryFieldChip extends StatelessWidget {
  const SmartEntryFieldChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.hasError = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final color = hasError ? scheme.error : scheme.onSurfaceVariant;

    return CcBouncing(
      onTap: onTap,
      borderRadius: context.brXl,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.respDim(12),
          vertical: context.respDim(8),
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: context.brXl,
          border: Border.all(
            color: hasError ? scheme.error : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CcIconToken(icon, color: color, size: 16),
            const CcSpaceXS(),
            Flexible(
              child: CcText(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textStyle: context.ccTextTheme.labelMedium?.copyWith(
                  color: hasError ? scheme.error : scheme.onSurface,
                ),
              ),
            ),
            const CcSpaceXS(),
            CcIconToken(Icons.expand_more_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}

class SmartEntryTypeToggle extends StatelessWidget {
  const SmartEntryTypeToggle({
    super.key,
    required this.types,
    required this.selected,
    required this.onChanged,
  });

  final List<String> types;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final type in types) ...[
          _buildOption(context, type),
          if (type != types.last) const CcSpaceSM(),
        ],
      ],
    );
  }

  Widget _buildOption(BuildContext context, String type) {
    final scheme = context.ccColorScheme;
    final isIncome = type == CategoryType.income;
    final accent = isIncome ? PrjColors.success : scheme.error;
    final isSelected = type == selected;

    return CcBouncing(
      onTap: () => onChanged(type),
      borderRadius: context.brXl,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.respDim(12),
          vertical: context.respDim(6),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.15)
              : scheme.surfaceContainerHighest,
          borderRadius: context.brXl,
          border: Border.all(
            color: isSelected
                ? accent.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: CcText(
          el.tr(
            isIncome ? CcLocaleKeys.common_income : CcLocaleKeys.common_expense,
          ),
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: isSelected ? accent : scheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class SmartEntryNoteField extends StatefulWidget {
  const SmartEntryNoteField({
    super.key,
    required this.note,
    required this.onChanged,
  });

  final String note;
  final ValueChanged<String> onChanged;

  @override
  State<SmartEntryNoteField> createState() => _SmartEntryNoteFieldState();
}

class _SmartEntryNoteFieldState extends State<SmartEntryNoteField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.note,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final textTheme = context.ccTextTheme;

    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      maxLines: 1,
      textInputAction: TextInputAction.done,
      style: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        hintText: el.tr(CcLocaleKeys.transaction_note_hint),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.4),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.respDim(12),
          vertical: context.respDim(10),
        ),
        border: OutlineInputBorder(
          borderRadius: context.brMd,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
