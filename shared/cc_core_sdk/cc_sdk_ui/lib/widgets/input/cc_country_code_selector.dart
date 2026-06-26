import 'package:flutter/material.dart';

import '../../export_cc_sdk_ui.dart';

class CcCountryCodeSelector extends StatelessWidget {
  const CcCountryCodeSelector({
    super.key,
    required this.countryCode,
    required this.onTap,
  });

  final String countryCode;
  final VoidCallback onTap;

  String _getFlagEmoji(String dialCode) {
    // Map of country dial codes to flag emojis
    const flagMap = {
      '1': '🇺🇸', // USA/Canada
      '84': '🇻🇳', // Vietnam
      '44': '🇬🇧', // UK
      '33': '🇫🇷', // France
      '49': '🇩🇪', // Germany
      '81': '🇯🇵', // Japan
      '86': '🇨🇳', // China
      '91': '🇮🇳', // India
      '61': '🇦🇺', // Australia
      '82': '🇰🇷', // South Korea
      '39': '🇮🇹', // Italy
      '34': '🇪🇸', // Spain
      '7': '🇷🇺', // Russia
      '46': '🇸🇪', // Sweden
      '47': '🇳🇴', // Norway
      '45': '🇩🇰', // Denmark
      '31': '🇳🇱', // Netherlands
      '41': '🇨🇭', // Switzerland
      '43': '🇦🇹', // Austria
      '32': '🇧🇪', // Belgium
      '351': '🇵🇹', // Portugal
      '358': '🇫🇮', // Finland
      '353': '🇮🇪', // Ireland
      '352': '🇱🇺', // Luxembourg
      '370': '🇱🇹', // Lithuania
      '371': '🇱🇻', // Latvia
      '372': '🇪🇪', // Estonia
      '48': '🇵🇱', // Poland
      '420': '🇨🇿', // Czech Republic
      '421': '🇸🇰', // Slovakia
      '36': '🇭🇺', // Hungary
      '40': '🇷🇴', // Romania
      '30': '🇬🇷', // Greece
      '90': '🇹🇷', // Turkey
      '20': '🇪🇬', // Egypt
      '27': '🇿🇦', // South Africa
      '234': '🇳🇬', // Nigeria
      '254': '🇰🇪', // Kenya
      '62': '🇮🇩', // Indonesia
      '63': '🇵🇭', // Philippines
      '66': '🇹🇭', // Thailand
      '60': '🇲🇾', // Malaysia
      '65': '🇸🇬', // Singapore
      '64': '🇳🇿', // New Zealand
      '52': '🇲🇽', // Mexico
      '56': '🇨🇱', // Chile
      '54': '🇦🇷', // Argentina
      '57': '🇨🇴', // Colombia
      '51': '🇵🇪', // Peru
      '55': '🇧🇷', // Brazil
      '58': '🇻🇪', // Venezuela
    };
    return flagMap[dialCode] ?? '🌐'; // Default globe icon
  }

  @override
  Widget build(BuildContext context) {
    // Extract country code without + sign for flag lookup
    final dialCode = countryCode.replaceAll('+', '');
    final flagEmoji = _getFlagEmoji(dialCode);

    return CcInkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        context.respDim(CcPaddingParams.DESC_SM),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.DESC_XS),
          vertical: context.respPadding(CcPaddingParams.DESC_XS),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: context.ccColorScheme.outline, width: 1),
          borderRadius: BorderRadius.circular(
            context.respDim(CcPaddingParams.DESC_SM),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CcText(
              flagEmoji,
              textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                fontSize: context.respDim(20),
              ),
            ),
            SizedBox(width: context.respPadding(CcPaddingParams.DESC_XS)),
            CcText(
              countryCode,
              textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                color: context.ccColorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
