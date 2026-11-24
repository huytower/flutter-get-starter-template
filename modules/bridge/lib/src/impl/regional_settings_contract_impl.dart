import 'package:app_config/data/datasources/local/box/app_storage/prj_app_storage.dart';
import 'package:domain_features/core/constant/currency_catalog.dart';
import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:injectable/injectable.dart';

import '../contracts/regional_settings_contract.dart';

@LazySingleton(as: RegionalSettingsContract)
class RegionalSettingsContractImpl implements RegionalSettingsContract {
  @override
  Stream<String> get detectedLanguageCode => CurrencyConstants
      .onRegionalSettingsChanged
      .stream
      .map(
        (_) => CurrencyCatalog.languageCodeForCountry(
          PrjAppStorage.instance.currencyDetectionCountryCode,
        ),
      )
      .where((code) => code != null)
      .cast<String>();
}
