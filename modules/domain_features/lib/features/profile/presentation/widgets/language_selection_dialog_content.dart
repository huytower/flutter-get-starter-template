import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageSelectionDialogContent extends StatefulWidget {
  const LanguageSelectionDialogContent({super.key});

  @override
  State<LanguageSelectionDialogContent> createState() =>
      _LanguageSelectionDialogContentState();
}

class _LanguageSelectionDialogContentState
    extends State<LanguageSelectionDialogContent> {
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ---- Header ----
        Container(
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
            textStyle: context.ccTextTheme.headlineSmall?.copyWith(
              color: scheme.onPrimary,
              fontSize: context.respFontSize(16),
              fontWeight: CcTypographyParams.semiBold,
            ),
          ),
        ),

        // ---- Body ----
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(context.respDim(24)),
              bottomRight: Radius.circular(context.respDim(24)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---- Language row ----
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
                  vertical: context.respPadding(CcPaddingParams.PAGE_SM),
                ),
                child: Row(
                  children: locales.map((locale) {
                    final bool isSelected =
                        locale.languageCode == _selectedLocale.languageCode;
                    final String label = locale.languageCode.toUpperCase();

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onLocaleTap(locale),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: EdgeInsets.only(
                            right: locale == locales.last
                                ? 0.0
                                : context.respDim(8),
                          ),
                          height: context.respDim(40),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? scheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              context.respDim(12),
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? scheme.primary
                                  : scheme.outline.withOpacity(0.1),
                            ),
                          ),
                          child: CcText(
                            label,
                            align: Alignment.center,
                            textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                              fontSize: context.respFontSize(14),
                              fontWeight: isSelected
                                  ? CcTypographyParams.bold
                                  : CcTypographyParams.regular,
                              color: isSelected
                                  ? scheme.onPrimary
                                  : scheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ---- Actions ----
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.respPadding(CcPaddingParams.PAGE_MD),
                  0,
                  context.respPadding(CcPaddingParams.PAGE_MD),
                  context.respPadding(CcPaddingParams.PAGE_XS),
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
                    SizedBox(width: context.respDim(8)),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_selectedLocale),
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
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
            ],
          ),
        ),
      ],
    );
  }
}
