import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../../../core/constant/currency_catalog.dart';
import '../../../../../core/constant/currency_constants.dart';
import '../../../../../core/helper/money_format_helper.dart';

class CurrencySelectionContentSheet extends StatefulWidget {
  const CurrencySelectionContentSheet({
    super.key,
    required this.initialCurrencyCode,
  });

  final String initialCurrencyCode;

  @override
  State<CurrencySelectionContentSheet> createState() =>
      _CurrencySelectionContentSheetState();
}

class _CurrencySelectionContentSheetState
    extends State<CurrencySelectionContentSheet> {
  // primaryCurrencyCode: User's selected default currency for new entries and reporting.
  late String _primaryCurrencyCode;
  bool _showHiddenTags = false;

  @override
  void initState() {
    super.initState();
    _primaryCurrencyCode = widget.initialCurrencyCode;
  }

  void _onCurrencyTap(String code) {
    setState(() {
      _primaryCurrencyCode = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    const currencies = CurrencyConstants.supportedCurrencyCodes;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context, scheme),
        _buildBody(context, scheme, currencies),
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
        tr(CcLocaleKeys.profile_currency),
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
    List<String> currencies,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCurrencyList(context, scheme, currencies),
          _buildDefaultCurrencyNotice(context, scheme),
          _buildProviderAttribution(context, scheme),
          const CcSpaceXS(),
          _buildHiddenTagsSection(context, scheme),
          _buildActions(context, scheme),
        ],
      ),
    );
  }

  Widget _buildDefaultCurrencyNotice(BuildContext context, ColorScheme scheme) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
        vertical: context.respPadding(CcPaddingParams.SPACE_XS),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              text: 'Primary currency is $_primaryCurrencyCode, ',
              style: context.ccTextTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withOpacity(0.7),
              ),
              children: [
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showHiddenTags = !_showHiddenTags;
                      });
                    },
                    child: Text(
                      'change it?',
                      style: context.ccTextTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderAttribution(BuildContext context, ColorScheme scheme) {
    return CcText(
      'Exchange rates provided by Frankfurter service',
      align: Alignment.center,
      textAlign: TextAlign.center,
      textStyle: context.ccTextTheme.labelSmall?.copyWith(
        color: scheme.onSurface.withOpacity(0.5),
      ),
    );
  }

  Widget _buildHiddenTagsSection(BuildContext context, ColorScheme scheme) {
    if (!_showHiddenTags) return const SizedBox.shrink();

    const currencies = CurrencyConstants.supportedCurrencyCodes;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.respPadding(CcPaddingParams.PAGE_MD),
        0,
        context.respPadding(CcPaddingParams.PAGE_MD),
        context.respPadding(CcPaddingParams.SPACE_XS),
      ),
      child: Wrap(
        spacing: context.respDim(8),
        runSpacing: context.respDim(8),
        children: currencies.map((code) {
          final isSelected =
              code.toUpperCase() == _primaryCurrencyCode.toUpperCase();
          final symbol = MoneyFormatter.getSymbol(code);
          return InkWell(
            onTap: () => _onCurrencyTap(code),
            borderRadius: context.brMd,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.respDim(10),
                vertical: context.respDim(6),
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? scheme.primary
                      : scheme.outline.withOpacity(0.3),
                  width: isSelected ? 1.5 : 1,
                ),
                borderRadius: context.brMd,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => _onCurrencyTap(code),
                      activeColor: scheme.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 6),
                  CcText(
                    symbol,
                    textStyle: context.ccTextTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? scheme.primary : scheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  CcText(
                    code,
                    textStyle: context.ccTextTheme.bodySmall?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? scheme.primary : scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrencyList(
    BuildContext context,
    ColorScheme scheme,
    List<String> currencies,
  ) {
    return CcSymmetricPadding(
      horizontal: CcPaddingParams.PAGE_MD,
      vertical: CcPaddingParams.SPACE_SM,
      child: Column(
        children: currencies
            .map((code) => _buildCurrencyTile(context, scheme, code))
            .toList(),
      ),
    );
  }

  Widget _buildCurrencyTile(
    BuildContext context,
    ColorScheme scheme,
    String code,
  ) {
    final bool isSelected =
        code.toUpperCase() == _primaryCurrencyCode.toUpperCase();
    final definition = CurrencyCatalog.getDefinition(code);
    final formattedSample = MoneyFormatter.formatWithSymbol(
      definition.sampleAmount,
      currencyCode: code,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: context.respDim(8)),
      child: CcBouncing(
        onTap: () => _onCurrencyTap(code),
        borderRadius: context.brMd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: context.respDim(60),
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
          ),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: isSelected
                ? scheme.primary.withOpacity(0.15)
                : scheme.surface,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CcText(
                    code,
                    textStyle: context.ccTextTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurfaceVariant.withOpacity(0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  CcText(
                    definition.name,
                    textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected
                          ? CcTypographyParams.bold
                          : CcTypographyParams.regular,
                      color: isSelected ? scheme.primary : scheme.onSurface,
                    ),
                  ),
                ],
              ),
              CcText(
                formattedSample,
                textStyle: context.ccTextTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? scheme.primary : PrjColors.success,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, ColorScheme scheme) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
        vertical: context.respPadding(CcPaddingParams.SPACE_XS),
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
            onPressed: () => Navigator.of(context).pop(_primaryCurrencyCode),
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
