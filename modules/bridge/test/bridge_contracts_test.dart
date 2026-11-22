import 'package:app_config/data/datasources/local/box/app_storage/cc_app_storage.dart';
import 'package:bridge/core/di/di.module.dart';
import 'package:bridge/export_bridge.dart';
import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:domain_features/features/budget_allocation/presentation/pages/budget_allocation_page.dart';
import 'package:domain_features/features/profile/presentation/pages/profile_page.dart';
import 'package:domain_features/features/transaction/presentation/pages/transaction_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injectable/injectable.dart' show GetItHelper;

void main() {
  group('DI', () {
    setUp(() async {
      await getIt.reset();
      await BridgePackageModule().init(GetItHelper(getIt));
    });

    tearDown(() => getIt.reset());

    test('registers every contract under its interface', () {
      expect(getIt.isRegistered<AppLifecycleProvider>(), isTrue);
      expect(getIt.isRegistered<MainShellProvider>(), isTrue);
      expect(getIt.isRegistered<RegionalSettingsContract>(), isTrue);
      expect(getIt.isRegistered<AuthCoordinator>(), isTrue);
    });

    test('resolves one shared instance per contract', () {
      expect(
        identical(getIt<MainShellProvider>(), getIt<MainShellProvider>()),
        isTrue,
      );
    });
  });

  group('MainTab.fromIndex', () {
    test('maps bar positions in display order', () {
      expect(MainTab.fromIndex(0), MainTab.budget);
      expect(MainTab.fromIndex(1), MainTab.entry);
      expect(MainTab.fromIndex(2), MainTab.profile);
    });

    test('falls back to the entry tab for an unknown index', () {
      expect(MainTab.fromIndex(-1), MainTab.entry);
      expect(MainTab.fromIndex(MainTab.values.length), MainTab.entry);
    });
  });

  group('MainShellProvider.buildTab', () {
    setUpAll(() async {
      await getIt.reset();
      await BridgePackageModule().init(GetItHelper(getIt));
    });

    tearDownAll(() => getIt.reset());

    test('returns the feature page of each tab', () {
      final shell = getIt<MainShellProvider>();
      expect(shell.buildTab(MainTab.budget), isA<BudgetAllocationPage>());
      expect(shell.buildTab(MainTab.entry), isA<TransactionPage>());
      expect(shell.buildTab(MainTab.profile), isA<ProfilePage>());
    });
  });

  group('RegionalSettingsContract.detectedLanguageCode', () {
    late RegionalSettingsContract regional;

    setUp(() async {
      await getIt.reset();
      await BridgePackageModule().init(GetItHelper(getIt));
      regional = getIt<RegionalSettingsContract>();
      CcAppStorage.instance = CcAppStorage();
    });

    tearDown(() => getIt.reset());

    test(
      'emits the language of a detected region and skips unmapped ones',
      () async {
        final emitted = expectLater(regional.detectedLanguageCode, emits('ja'));

        // FR has a currency but no app language: nothing is emitted.
        CcAppStorage.instance.currencyDetectionCountryCode = 'FR';
        CurrencyConstants.onRegionalSettingsChanged.value++;
        await Future<void>.delayed(Duration.zero);

        CcAppStorage.instance.currencyDetectionCountryCode = 'JP';
        CurrencyConstants.onRegionalSettingsChanged.value++;

        await emitted;
      },
    );
  });
}
