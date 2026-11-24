import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

/// Content of the reconciliation guide sheet: a gradient title header, the
/// guide rows (icon + text) and a single close action.
class ReconciliationGuideContentSheet extends StatelessWidget {
  const ReconciliationGuideContentSheet({super.key});

  /// What reconciliation is, then how to do it (count -> compare -> record),
  /// then when it is due.
  static const List<({IconData icon, String textKey})> _items = [
    (
      icon: Icons.info_outline_rounded,
      textKey: PrjLocaleKeys.reconciliation_description_line_1,
    ),
    (
      icon: Icons.sync_alt_rounded,
      textKey: PrjLocaleKeys.reconciliation_description_line_2,
    ),
    (
      icon: Icons.paid_outlined,
      textKey: PrjLocaleKeys.reconciliation_guide_count,
    ),
    (
      icon: Icons.balance_rounded,
      textKey: PrjLocaleKeys.reconciliation_guide_compare,
    ),
    (
      icon: Icons.menu_book_rounded,
      textKey: PrjLocaleKeys.reconciliation_guide_record,
    ),
    (
      icon: Icons.event_repeat_rounded,
      textKey: PrjLocaleKeys.reconciliation_cycle_subtitle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    // Capped below the status bar; the rows scroll when they do not fit.
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, scheme),
          Flexible(child: _buildBody(context, scheme)),
        ],
      ),
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
      child: CcText(
        tr(PrjLocaleKeys.reconciliation_title),
        maxLines: 1,
        textStyle: context.ccTextTheme.titleLarge?.copyWith(
          color: scheme.onPrimary,
          fontWeight: CcTypographyParams.semiBold,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme scheme) {
    return DecoratedBox(
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: _buildGuideList(context, scheme)),
            _buildActions(context, scheme),
            const CcSpaceMD(),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideList(BuildContext context, ColorScheme scheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.PAGE_MD)),
      child: _buildItems(context, scheme),
    );
  }

  Widget _buildItems(BuildContext context, ColorScheme scheme) {
    final items = [
      for (final item in _items)
        _buildGuideItem(context, scheme, item.icon, tr(item.textKey)),
    ];
    // Small tablet and up (>= 600 dp window): two columns, so the sheet is
    // wider and shorter instead of one long column.
    if (context.windowSizeClass.hasAtLeast(CcWindowSizeClass.medium)) {
      return CcMultiColumn(
        columns: 2,
        columnGap: context.respPadding(CcPaddingParams.SPACE_LG),
        rowGap: context.respPadding(CcPaddingParams.SPACE_MD),
        children: items,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, item) in items.indexed) ...[
          if (index > 0) const CcSpaceMD(),
          item,
        ],
      ],
    );
  }

  Widget _buildGuideItem(
    BuildContext context,
    ColorScheme scheme,
    IconData icon,
    String text,
  ) {
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
        Expanded(child: _buildHighlightedText(context, scheme, text)),
      ],
    );
  }

  /// Renders [text] with every `**keyword**` run emphasized in the primary
  /// color and bold, so the key step or button name stands out. Plain parts
  /// keep the muted body color. Plain `Text.rich` is used (not `CcText`, which
  /// takes a single string and style).
  Widget _buildHighlightedText(
    BuildContext context,
    ColorScheme scheme,
    String text,
  ) {
    final baseStyle = context.ccTextTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
      height: 1.4,
    );
    final keywordStyle = baseStyle?.copyWith(
      color: scheme.primary,
      fontWeight: CcTypographyParams.bold,
    );

    // Splitting on the marker alternates plain / keyword / plain / ...; an
    // unmatched marker simply leaves the tail as a keyword, never throws.
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

  Widget _buildActions(BuildContext context, ColorScheme scheme) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: CcText(
              tr(PrjLocaleKeys.common_ok),
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
