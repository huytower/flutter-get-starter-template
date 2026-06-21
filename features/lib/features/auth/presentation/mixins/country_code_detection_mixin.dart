import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter/widgets.dart';

mixin CountryCodeDetectionMixin<T extends StatefulWidget> on State<T> {
  String countryCode = CcLocationHelper.defaultCountryCode;

  Future<void> detectCountryCode() async {
    try {
      final hasPermission =
          await CcLocationHelper.isLocationPermissionGranted();
      if (!hasPermission) {
        final granted = await CcLocationHelper.requestLocationPermission();
        if (!granted) {
          // Keep default country code if permission denied
          return;
        }
      }

      final detectedCountryCode = await CcLocationHelper.getCountryCode();
      if (mounted) {
        setState(() {
          countryCode = detectedCountryCode;
        });
      }
    } catch (e) {
      // Keep default country code on error
    }
  }
}
