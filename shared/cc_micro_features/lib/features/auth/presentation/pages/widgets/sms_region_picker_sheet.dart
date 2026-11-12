import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../domain/sms_supported_regions.dart';

/// Bottom sheet listing the countries SMS verification is available for.
///
/// Styled like the currency picker (gradient header, glassy cards on a tinted
/// body). Each row shows only flag, ISO code and dial code; the header reuses
/// the existing "Phone Number" string. Pops with the chosen [SmsRegion].
class SmsRegionPickerSheet extends StatelessWidget {
  const SmsRegionPickerSheet({super.key, required this.selectedDialCode});

  final String selectedDialCode;

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
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
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
    return DecoratedBox(
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(
          context.respPadding(CcPaddingParams.PAGE_MD),
          context.respPadding(CcPaddingParams.SPACE_SM),
          context.respPadding(CcPaddingParams.PAGE_MD),
          context.respPadding(CcPaddingParams.SPACE_XL),
        ),
        itemCount: _popularRegions.length + _otherRegions.length,
        itemBuilder: (context, index) {
          if (index < _popularRegions.length) {
            final tile = _buildRegionTile(
              context,
              scheme,
              _popularRegions[index],
            );
            // Separate the popular group from the alphabetical one.
            return index == _popularRegions.length - 1
                ? Padding(
                    padding: EdgeInsets.only(bottom: context.respDim(8)),
                    child: Column(
                      children: [
                        tile,
                        Divider(
                          color: scheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  )
                : tile;
          }
          return _buildRegionTile(
            context,
            scheme,
            _otherRegions[index - _popularRegions.length],
          );
        },
      ),
    );
  }

  Widget _buildRegionTile(
    BuildContext context,
    ColorScheme scheme,
    SmsRegion region,
  ) {
    final isSelected = region.dialCode == selectedDialCode;

    return Padding(
      padding: EdgeInsets.only(bottom: context.respDim(8)),
      child: CcBouncing(
        onTap: () => Navigator.of(context).pop(region),
        borderRadius: context.brMd,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned.fill(child: CcGlassyGradientBackground()),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: context.respDim(60),
              padding: EdgeInsets.symmetric(
                horizontal: context.respPadding(CcPaddingParams.PAGE_XS),
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? scheme.primary.withValues(alpha: 0.15)
                    : scheme.primaryContainer.withValues(alpha: 0.1),
              ),
              child: Row(
                children: [
                  Container(
                    width: context.respDim(32),
                    height: context.respDim(32),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: CcText(
                      region.flag,
                      textAlign: TextAlign.center,
                      align: Alignment.center,
                      textStyle: TextStyle(fontSize: context.respFontSize(16)),
                    ),
                  ),
                  const CcSpaceSM(),
                  Expanded(
                    child: CcText(
                      region.isoCode,
                      textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected
                            ? CcTypographyParams.bold
                            : CcTypographyParams.regular,
                        color: isSelected ? scheme.primary : scheme.onSurface,
                      ),
                    ),
                  ),
                  const CcSpaceSM(),
                  CcText(
                    region.dialCode,
                    textStyle: context.ccTextTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? scheme.primary : scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
