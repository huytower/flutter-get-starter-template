import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageSelectionContentSheet extends StatefulWidget {
  const LanguageSelectionContentSheet({super.key});

  @override
  State<LanguageSelectionContentSheet> createState() =>
      _LanguageSelectionContentSheetState();
}

class _LanguageSelectionContentSheetState
    extends State<LanguageSelectionContentSheet> {
  late Locale _selectedLocale;

  @override
  void initState() {
    super.initState();
    // We'll initialize in didChangeDependencies to have access to context.locale
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLocale = context.locale;
  }

  void _onLocaleTap(Locale locale) {
    setState(() {
      _selectedLocale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    const locales = CcLocalization.supportedLocales;

    return Wrap(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, scheme),
            _buildBody(context, scheme, locales),
          ],
        ),
      ],
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
        tr(CcLocaleKeys.settings_language),
        maxLines: 1,
        textStyle: context.ccTextTheme.titleLarge?.copyWith(
          color: scheme.onPrimary,
          fontWeight: CcTypographyParams.semiBold,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ColorScheme scheme,
    List<Locale> locales,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.respDim(24)),
          bottomRight: Radius.circular(context.respDim(24)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageGrid(context, scheme, locales),
            _buildActions(context, scheme),
            const CcSpaceMD(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageGrid(
    BuildContext context,
    ColorScheme scheme,
    List<Locale> locales,
  ) {
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
        itemCount: locales.length,
        itemBuilder: (context, index) {
          return _buildLanguageChip(context, scheme, locales[index], locales);
        },
      ),
    );
  }

  Widget _buildLanguageChip(
    BuildContext context,
    ColorScheme scheme,
    Locale locale,
    List<Locale> locales,
  ) {
    final bool isSelected = locale.languageCode == _selectedLocale.languageCode;
    final String label = _getLanguageLabel(locale);
    final String flag = _getLanguageFlag(locale);

    return CcBouncing(
      onTap: () => _onLocaleTap(locale),
      borderRadius: context.brMd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: context.respDim(12)),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: isSelected ? scheme.primary.withOpacity(0.1) : scheme.surface,
          borderRadius: context.brMd,
          border: Border.all(
            color: isSelected
                ? scheme.primary
                : scheme.outline.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: TextStyle(fontSize: context.respFontSize(16))),
            const CcSpaceSM(),
            Expanded(
              child: CcText(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textStyle: context.ccTextTheme.bodySmall?.copyWith(
                  fontWeight: isSelected
                      ? CcTypographyParams.bold
                      : CcTypographyParams.medium,
                  color: isSelected ? scheme.primary : scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'vi':
        return '🇻🇳';
      case 'ko':
        return '🇰🇷';
      case 'ja':
        return '🇯🇵';
      case 'zh':
        return '🇨🇳';
      case 'en':
      default:
        return '🇺🇸';
    }
  }

  String _getLanguageLabel(Locale locale) {
    switch (locale.languageCode) {
      case 'vi':
        return tr(CcLocaleKeys.settings_language_vietnamese);
      case 'ko':
        return tr(CcLocaleKeys.settings_language_korean);
      case 'ja':
        return tr(CcLocaleKeys.settings_language_japanese);
      case 'zh':
        return tr(CcLocaleKeys.settings_language_chinese);
      case 'en':
      default:
        return tr(CcLocaleKeys.settings_language_english);
    }
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
            onPressed: () => Navigator.of(context).pop(null),
            child: CcText(
              tr(CcLocaleKeys.common_cancel),
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                color: scheme.primary,
                fontWeight: CcTypographyParams.semiBold,
              ),
            ),
          ),
          const CcSpaceSM(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selectedLocale),
            child: CcText(
              tr(CcLocaleKeys.common_ok),
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
