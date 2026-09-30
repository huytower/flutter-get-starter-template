import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constant/currency_constants.dart';
import '../../../../../core/helper/money_format_helper.dart';

class CurrencySelectionDialogContent extends StatefulWidget {
  const CurrencySelectionDialogContent({
    super.key,
    required this.initialCurrencyCode,
  });

  final String initialCurrencyCode;

  @override
  State<CurrencySelectionDialogContent> createState() =>
      _CurrencySelectionDialogContentState();
}

class _CurrencySelectionDialogContentState
    extends State<CurrencySelectionDialogContent> {
  late String _selectedCurrencyCode;

  @override
  void initState() {
    super.initState();
    _selectedCurrencyCode = widget.initialCurrencyCode;
  }

  void _onCurrencyTap(String code) {
    setState(() {
      _selectedCurrencyCode = code;
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
          _buildCurrencyList(context, scheme, currencies),
          _buildActions(context, scheme),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
        ],
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
      vertical: CcPaddingParams.PAGE_SM,
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
        code.toUpperCase() == _selectedCurrencyCode.toUpperCase();
    final symbol = MoneyFormatter.getSymbol(code);

    return Padding(
      padding: EdgeInsets.only(bottom: context.respDim(8)),
      child: CcBouncing(
        onTap: () => _onCurrencyTap(code),
        borderRadius: context.brMd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: context.respDim(50),
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
          ),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: isSelected
                ? scheme.primary.withOpacity(0.15)
                : scheme.surface,
            borderRadius: context.brMd,
            border: Border.all(
              color: isSelected
                  ? scheme.primary
                  : scheme.outline.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CcText(
                '$code ($symbol)',
                textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected
                      ? CcTypographyParams.bold
                      : CcTypographyParams.regular,
                  color: isSelected ? scheme.primary : scheme.onSurface,
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_rounded,
                  color: scheme.primary,
                  size: context.respIconSize(baseSize: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, ColorScheme scheme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.respPadding(CcPaddingParams.PAGE_MD),
        0,
        context.respPadding(CcPaddingParams.PAGE_MD),
        context.respPadding(CcPaddingParams.SPACE_XS),
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
            onPressed: () => Navigator.of(context).pop(_selectedCurrencyCode),
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
