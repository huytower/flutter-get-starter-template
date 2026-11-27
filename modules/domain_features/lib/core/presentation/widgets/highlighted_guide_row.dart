import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// One bullet of an explanation sheet: a round tinted [icon] and the [text],
/// in which every `**keyword**` run is emphasized in the primary color and
/// bold, so the key step or button name stands out.
class HighlightedGuideRow extends StatelessWidget {
  const HighlightedGuideRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(context.respDim(6)),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: context.respIconSize(baseSize: 18),
            color: scheme.primary,
          ),
        ),
        const CcSpaceSM(),
        Expanded(child: _buildText(context, scheme)),
      ],
    );
  }

  /// Plain `Text.rich` (not `CcText`, which takes a single string and style).
  /// Splitting on the marker alternates plain / keyword / plain / ...; an
  /// unmatched marker simply leaves the tail as a keyword, never throws.
  Widget _buildText(BuildContext context, ColorScheme scheme) {
    final baseStyle = context.ccTextTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
      height: 1.4,
    );
    final keywordStyle = baseStyle?.copyWith(
      color: scheme.primary,
      fontWeight: CcTypographyParams.bold,
    );
    final parts = text.split('**');
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          for (final (index, part) in parts.indexed)
            if (part.isNotEmpty)
              TextSpan(text: part, style: index.isOdd ? keywordStyle : null),
        ],
      ),
      textAlign: TextAlign.start,
    );
  }
}
