import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../domain/sms_supported_regions.dart';

/// Bottom sheet listing the countries SMS verification is available for.
///
/// Styled like the currency picker (gradient header, glassy cards on a tinted
/// body) with the countries laid out in a 3-column grid. Each card shows only
/// flag, ISO code and dial code; the header reuses the existing "Phone Number"
/// string. Pops with the chosen [SmsRegion].
class SmsRegionPickerSheet extends StatelessWidget {
  const SmsRegionPickerSheet({super.key, required this.selectedDialCode});

  final String selectedDialCode;

  /// Share of the screen height the sheet occupies.
  static const double sheetHeightFactor = 0.45;

  static const int _columns = 3;

  /// Countries of the app's languages, in the same order as the language
  /// picker (vi, en, ko, ja, zh). Shown first; the rest follow alphabetically.
  static const List<String> _popularIsoCodes = ['VN', 'US', 'KR', 'JP', 'CN'];

  static final List<SmsRegion> _popularRegions = [
    for (final iso in _popularIsoCodes)
      ...smsSupportedRegions.where((r) => r.isoCode == iso),
  ];

  static final List<SmsRegion> _otherRegions =
      smsSupportedRegions
          .where((r) => !_popularIsoCodes.contains(r.isoCode))
          .toList()
        ..sort((a, b) => a.isoCode.compareTo(b.isoCode));

  static Future<SmsRegion?> show(
    BuildContext context, {
    required String selectedDialCode,
  }) {
    return showModalBottomSheet<SmsRegion>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SmsRegionPickerSheet(selectedDialCode: selectedDialCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return SizedBox(
      height: MediaQuery.of(context).size.height * sheetHeightFactor,
      child: Column(
        children: [
          _buildHeader(context, scheme),
          Expanded(child: _buildBody(context, scheme)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
        vertical: context.respPadding(CcPaddingParams.SPACE_MD),
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
        el.tr(CcLocaleKeys.auth_phone_number),
        maxLines: 1,
        textStyle: context.ccTextTheme.titleLarge?.copyWith(
          color: scheme.onPrimary,
          fontWeight: CcTypographyParams.semiBold,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme scheme) {
    final padding = context.respPadding(CcPaddingParams.PAGE_MD);

    return DecoratedBox(
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              padding,
              context.respPadding(CcPaddingParams.SPACE_SM),
              padding,
              0,
            ),
            sliver: _buildGrid(context, scheme, _popularRegions),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: context.respPadding(CcPaddingParams.SPACE_SM),
              ),
              child: Divider(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              padding,
              0,
              padding,
              context.respPadding(CcPaddingParams.SPACE_XL),
            ),
            sliver: _buildGrid(context, scheme, _otherRegions),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    ColorScheme scheme,
    List<SmsRegion> regions,
  ) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns,
        mainAxisSpacing: context.respDim(8),
        crossAxisSpacing: context.respDim(8),
        mainAxisExtent: context.respDim(76),
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildRegionTile(context, scheme, regions[index]),
        childCount: regions.length,
      ),
    );
  }

  Widget _buildRegionTile(
    BuildContext context,
    ColorScheme scheme,
    SmsRegion region,
  ) {
    final isSelected = region.dialCode == selectedDialCode;
    final textColor = isSelected ? scheme.primary : scheme.onSurface;

    return CcBouncing(
      onTap: () => Navigator.of(context).pop(region),
      borderRadius: context.brMd,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: CcGlassyGradientBackground()),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: context.respPadding(CcPaddingParams.SPACE_XS),
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? scheme.primary.withValues(alpha: 0.15)
                  : scheme.primaryContainer.withValues(alpha: 0.1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CcText(
                  region.flag,
                  textAlign: TextAlign.center,
                  align: Alignment.center,
                  textStyle: TextStyle(fontSize: context.respFontSize(22)),
                ),
                const SizedBox(height: 2),
                CcText(
                  '${region.isoCode}  ${region.dialCode}',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  align: Alignment.center,
                  textStyle: context.ccTextTheme.labelMedium?.copyWith(
                    fontWeight: isSelected
                        ? CcTypographyParams.bold
                        : CcTypographyParams.semiBold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
