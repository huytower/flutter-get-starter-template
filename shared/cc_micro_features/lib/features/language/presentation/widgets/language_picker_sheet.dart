import 'package:cc_micro_features/l10n/cc_mf_locale_keys.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

/// Bottom sheet for choosing the app language: a two-column grid of flags and
/// language names, then Cancel / OK. Returns the picked [Locale], or `null`
/// when cancelled. The caller applies it (for example
/// `EasyLocalization.of(context)!.setLocale(picked)`).
///
/// Names and flags are built in for en, vi, ko, ja and zh; any other locale
/// shows its language code and a globe.
///
/// ```dart
/// final picked = await LanguagePickerSheet.show(
///   context,
///   locales: const [Locale('en'), Locale('vi')],
/// );
/// ```
class LanguagePickerSheet extends StatefulWidget {
  const LanguagePickerSheet({super.key, required this.locales});

  final List<Locale> locales;

  static Future<Locale?> show(
    BuildContext context, {
    required List<Locale> locales,
  }) {
    return CcAdaptiveBottomSheet.show<Locale>(
      context: context,
      builder: (_) => LanguagePickerSheet(locales: locales),
    );
  }

  static const Map<String, String> _flags = {
    'en': '🇺🇸',
    'vi': '🇻🇳',
    'ko': '🇰🇷',
    'ja': '🇯🇵',
    'zh': '🇨🇳',
  };

  static const Map<String, String> _nameKeys = {
    'en': CcMfLocaleKeys.language_english,
    'vi': CcMfLocaleKeys.language_vietnamese,
    'ko': CcMfLocaleKeys.language_korean,
    'ja': CcMfLocaleKeys.language_japanese,
    'zh': CcMfLocaleKeys.language_chinese,
  };

  /// Flag emoji of [locale]'s language, or a globe when unknown.
  static String flagOf(Locale locale) => _flags[locale.languageCode] ?? '🌐';

  /// Translated name of [locale]'s language, or its code when unknown.
  static String nameOf(Locale locale) {
    final key = _nameKeys[locale.languageCode];
    return key == null ? locale.languageCode.toUpperCase() : el.tr(key);
  }

  @override
  State<LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<LanguagePickerSheet> {
  Locale? _selectedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLocale ??= Localizations.localeOf(context);
  }

  @override
  Widget build(BuildContext context) {
    return CcPickerSheetFrame(
      title: el.tr(CcMfLocaleKeys.language_title),
      body: _buildLanguageGrid(context),
      onConfirm: () => Navigator.of(context).pop(_selectedLocale),
    );
  }

  Widget _buildLanguageGrid(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.PAGE_MD)),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: context.respDim(50),
          crossAxisSpacing: context.respDim(12),
          mainAxisSpacing: context.respDim(12),
        ),
        itemCount: widget.locales.length,
        itemBuilder: (context, index) =>
            _buildLanguageChip(context, widget.locales[index]),
      ),
    );
  }

  Widget _buildLanguageChip(BuildContext context, Locale locale) {
    final scheme = context.ccColorScheme;
    final hasSelected = locale.languageCode == _selectedLocale?.languageCode;
    return CcBouncing(
      onTap: () => setState(() => _selectedLocale = locale),
      borderRadius: context.brMd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: context.respDim(12)),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: hasSelected
              ? scheme.primary.withValues(alpha: 0.1)
              : scheme.surface,
          borderRadius: context.brMd,
          border: Border.all(
            color: hasSelected
                ? scheme.primary
                : scheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            CcText(
              LanguagePickerSheet.flagOf(locale),
              textStyle: context.ccTextTheme.titleMedium,
            ),
            const CcSpaceSM(),
            Expanded(
              child: CcText(
                LanguagePickerSheet.nameOf(locale),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textStyle: context.ccTextTheme.bodySmall?.copyWith(
                  fontWeight: hasSelected
                      ? CcTypographyParams.bold
                      : CcTypographyParams.medium,
                  color: hasSelected ? scheme.primary : scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
