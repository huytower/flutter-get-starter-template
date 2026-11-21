// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:bridge/src/contracts/app_lifecycle_provider.dart' as _i1025;
import 'package:bridge/src/contracts/book_currency_provider.dart' as _i13;
import 'package:bridge/src/contracts/main_shell_provider.dart' as _i883;
import 'package:bridge/src/contracts/regional_settings_contract.dart' as _i91;
import 'package:bridge/src/coordinators/auth_coordinator_impl.dart' as _i103;
import 'package:bridge/src/impl/app_lifecycle_provider_impl.dart' as _i243;
import 'package:bridge/src/impl/book_currency_provider_impl.dart' as _i849;
import 'package:bridge/src/impl/financial_refresh_provider_impl.dart' as _i139;
import 'package:bridge/src/impl/guideline_provider_impl.dart' as _i490;
import 'package:bridge/src/impl/main_shell_provider_impl.dart' as _i598;
import 'package:bridge/src/impl/regional_settings_contract_impl.dart' as _i576;
import 'package:bridge/src/impl/user_level_provider_impl.dart' as _i533;
import 'package:cc_bridge/export_cc_bridge.dart' as _i727;
import 'package:domain_features/core/contracts/financial_refresh_provider.dart'
    as _i953;
import 'package:domain_features/core/currency/book_currency_aligner.dart'
    as _i62;
import 'package:domain_features/export_domain_features.dart' as _i857;
import 'package:domain_features/features/profile/domain/usecases/get_profile_settings_usecase.dart'
    as _i569;
import 'package:injectable/injectable.dart' as _i526;

class BridgePackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.lazySingleton<_i857.GuidelineProvider>(
        () => _i490.GuidelineProviderImpl());
    gh.lazySingleton<_i857.FinancialRefreshProvider>(
        () => _i139.FinancialRefreshProviderImpl());
    gh.lazySingleton<_i91.RegionalSettingsContract>(
        () => _i576.RegionalSettingsContractImpl());
    gh.lazySingleton<_i883.MainShellProvider>(
        () => _i598.MainShellProviderImpl());
    gh.lazySingleton<_i1025.AppLifecycleProvider>(
        () => _i243.AppLifecycleProviderImpl());
    gh.lazySingleton<_i727.AuthCoordinator>(() => _i103.AuthCoordinatorImpl());
    gh.lazySingleton<_i857.UserLevelProvider>(
        () => _i533.UserLevelProviderImpl(gh<_i857.UserLevelController>()));
    gh.lazySingleton<_i13.BookCurrencyProvider>(
        () => _i849.BookCurrencyProviderImpl(
              gh<_i62.BookCurrencyAligner>(),
              gh<_i953.FinancialRefreshProvider>(),
              gh<_i569.GetProfileSettingsUseCase>(),
            ));
  }
}
