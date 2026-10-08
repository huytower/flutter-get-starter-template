import 'dart:math';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theme/export_theme.dart';

import '../../../../../core/constant/currency_catalog.dart';
import '../../../../../core/constant/currency_constants.dart';
import '../../../../../core/getx/cc_get_view.dart';
import '../../../../../core/helper/money_format_helper.dart';
import '../get_x/currency_selection_controller.dart';

class CurrencySelectionContentSheet
    extends CcGetView<CurrencySelectionController> {
  const CurrencySelectionContentSheet({
    super.key,
    required this.initialCurrencyCode,
  });

  final String initialCurrencyCode;

  @override
  bool get enableAppBar => false;

  @override
  bool get enableBottomNavigationBar => false;

  @override
  bool get useSafeArea => false;

  @override
  bool get enableLoading => false;

  @override
  CcLayoutStatus get layoutStatus => CcLayoutStatus.success;

  @override
  Widget onPageBodyWrapper(BuildContext context, Widget body) {
    return Align(alignment: Alignment.bottomCenter, child: body);
  }

  @override
  Widget? buildContent(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isInitialized) {
        controller.init(initialCurrencyCode);
      }
    });

    final scheme = context.ccColorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [_buildHeader(context, scheme), _buildBody(context, scheme)],
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
        el.tr(CcLocaleKeys.profile_currency),
        maxLines: 1,
        textStyle: context.ccTextTheme.titleLarge?.copyWith(
          color: scheme.onPrimary,
          fontWeight: CcTypographyParams.semiBold,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme scheme) {
    final currencies = CurrencyConstants.supportedCurrencyCodes
        .where(
          (code) =>
              code.toUpperCase() !=
              controller.primaryCurrencyCode.value.toUpperCase(),
        )
        .toList();

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
              text:
                  'Primary currency is ${controller.primaryCurrencyCode.value}, ',
              style: context.ccTextTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withOpacity(0.7),
              ),
              children: [
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => controller.toggleHiddenTags(),
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
    if (!controller.showHiddenTags.value) return const SizedBox.shrink();

    final currencies = CurrencyConstants.supportedCurrencyCodes
        .where(
          (code) =>
              code.toUpperCase() !=
              controller.primaryCurrencyCode.value.toUpperCase(),
        )
        .toList();
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
              code.toUpperCase() ==
              controller.primaryCurrencyCode.value.toUpperCase();
          final symbol = MoneyFormatter.getSymbol(code);
          return InkWell(
            onTap: () {
              '[CurrencySelectionContentSheet] Tag selected base currency: $code'
                  .Log();
              controller.setPrimaryCurrency(code);
            },
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
                      onChanged: (_) {
                        '[CurrencySelectionContentSheet] Tag checkbox selected base currency: $code'
                            .Log();
                        controller.setPrimaryCurrency(code);
                      },
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
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
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
    final definition = CurrencyCatalog.getDefinition(code);

    final isSelected =
        code.toUpperCase() ==
        controller.primaryCurrencyCode.value.toUpperCase();
    final isLoading = controller.isLoadingRates[code] ?? false;
    final convertedAmount = controller.convertedAmounts[code];
    final String displayAmount;

    final baseCurrency = controller.primaryCurrencyCode.value;
    final bool isBaseVnd = baseCurrency.toUpperCase() == 'VND';
    final formatCurrencyCode = isBaseVnd ? baseCurrency : code;
    final formatDefinition = CurrencyCatalog.getDefinition(formatCurrencyCode);

    if (isLoading && convertedAmount == null) {
      displayAmount = '...';
    } else if (convertedAmount != null) {
      final scale = pow(10, formatDefinition.decimalDigits).toDouble();
      final majorValue = convertedAmount / scale;

      if (formatDefinition.decimalDigits > 0) {
        final formatter = NumberFormat(
          '#,##0.${'0' * formatDefinition.decimalDigits}',
          CurrencyConstants.getLocale(formatCurrencyCode),
        );
        final formattedNum = formatter.format(majorValue);
        displayAmount = formatDefinition.isPrefixSymbol
            ? '${formatDefinition.symbol}$formattedNum'
            : '$formattedNum ${formatDefinition.symbol}';
      } else {
        displayAmount = MoneyFormatter.formatWithSymbol(
          convertedAmount,
          currencyCode: formatCurrencyCode,
        );
      }
    } else {
      displayAmount = 'N/A';
    }

    return Padding(
      padding: EdgeInsets.only(bottom: context.respDim(8)),
      child: CcBouncing(
        onTap: () {
          '[CurrencySelectionContentSheet] Tile selected base currency: $code'
              .Log();
          controller.setPrimaryCurrency(code);
        },
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
                    el.tr(definition.nameKey),
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
                displayAmount,
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
            onPressed: () {
              '[CurrencySelectionContentSheet] Cancel currency selection'.Log();
              Navigator.of(context).pop(null);
            },
            child: CcText(
              el.tr(CcLocaleKeys.common_cancel),
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                color: scheme.primary,
                fontWeight: CcTypographyParams.semiBold,
              ),
            ),
          ),
          const CcSpaceSM(),
          TextButton(
            onPressed: () {
              final selectedCode = controller.primaryCurrencyCode.value;
              '[CurrencySelectionContentSheet] Confirmed base currency: $selectedCode'
                  .Log();
              Navigator.of(context).pop(selectedCode);
            },
            child: CcText(
              el.tr(CcLocaleKeys.common_ok),
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
