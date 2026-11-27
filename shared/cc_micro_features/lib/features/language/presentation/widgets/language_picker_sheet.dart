import 'package:cc_micro_features/l10n/cc_mf_locale_keys.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

/// Bottom sheet for choosing the app language: one tile per language (flag,
/// code and name; two columns from a small tablet up), then Cancel / OK.
/// Returns the picked [Locale], or `null` when cancelled. The caller applies it
/// (for example `EasyLocalization.of(context)!.setLocale(picked)`).
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
      body: _buildLanguageList(context),
      onConfirm: () => Navigator.of(context).pop(_selectedLocale),
    );
  }

  Widget _buildLanguageList(BuildContext context) {
    final tiles = [
      for (final locale in widget.locales) _buildLanguageTile(context, locale),
    ];
    // The sheet is narrower than the window, so the window class decides.
    final hasTwoColumns = context.windowSizeClass.hasAtLeast(
      CcWindowSizeClass.medium,
    );
    return CcSymmetricPadding(
      horizontal: CcPaddingParams.PAGE_MD,
      vertical: CcPaddingParams.SPACE_SM,
      child: hasTwoColumns
          ? CcMultiColumn(
              columns: 2,
              columnGap: context.respDim(8),
              children: tiles,
            )
          : Column(mainAxisSize: MainAxisSize.min, children: tiles),
    );
  }

  Widget _buildLanguageTile(BuildContext context, Locale locale) {
    final code = locale.languageCode;
    // An unknown language already shows its code as the name.
    final hasName = LanguagePickerSheet._nameKeys.containsKey(code);
    return Padding(
      padding: EdgeInsets.only(bottom: context.respDim(8)),
      child: CcOptionTile(
        leading: Text(LanguagePickerSheet.flagOf(locale)),
        overline: hasName ? code.toUpperCase() : null,
        title: LanguagePickerSheet.nameOf(locale),
        hasSelected: code == _selectedLocale?.languageCode,
        onTap: () => setState(() => _selectedLocale = locale),
      ),
    );
  }
}
