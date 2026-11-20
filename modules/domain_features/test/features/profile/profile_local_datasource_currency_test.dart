import 'dart:async';
import 'dart:io';

import 'package:app_config/data/datasource/local/box/app_storage/cc_app_storage.dart';
import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:domain_features/core/constant/currency_catalog.dart';
import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:domain_features/features/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

typedef _Gps = ({String currencyCode, String? countryCode});

void main() {
  late Directory tempDir;
  late String localeCurrency;
  late String gpsCurrency;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = Directory.systemTemp.createTempSync('profile_currency_test');
    Hive.init(tempDir.path);
    await CcAppStorage.register();
    localeCurrency =
        CurrencyCatalog.detectSuggestedCurrencyWithDetails().currencyCode;
    gpsCurrency = localeCurrency == CurrencyConstants.jpy
        ? CurrencyConstants.usd
        : CurrencyConstants.jpy;
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  setUp(() async {
    final box = Hive.box<CcAppStorage>(CcHiveBox.APP_BOX_NAME);
    await box.clear();
    final fresh = CcAppStorage();
    await box.put(CcHiveBox.keyDefault, fresh);
    CcAppStorage.instance = fresh;
  });

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 150));

  ProfileLocalDataSource dataSource(
    Future<_Gps> Function() detector, {
    Duration timeout = const Duration(milliseconds: 60),
  }) => ProfileLocalDataSource.withGpsDetector(detector, timeout: timeout);

  group('first launch (no stored currency)', () {
    test(
      'returns immediately with the locale currency while GPS never answers',
      () async {
        final neverAnswers = Completer<_Gps>();

        final settings = await dataSource(
          () => neverAnswers.future,
          timeout: const Duration(seconds: 30),
        ).getSettings().timeout(const Duration(seconds: 2));

        expect(settings.currencyCode, localeCurrency);
        expect(settings.currencySelectionSource, 'detected');
        expect(CcAppStorage.instance.currencyCode, localeCurrency);
      },
    );

    test(
      'a GPS answer for another currency refines it and broadcasts the change',
      () async {
        final before = CurrencyConstants.onCurrencyChanged.value;

        await dataSource(
          () async => (currencyCode: gpsCurrency, countryCode: 'ZZ'),
        ).getSettings();
        await settle();

        expect(CcAppStorage.instance.currencyCode, gpsCurrency);
        expect(CcAppStorage.instance.currencyDetectionCountryCode, 'ZZ');
        expect(CurrencyConstants.onCurrencyChanged.value, before + 1);
      },
    );

    test(
      'a GPS answer matching the locale currency broadcasts nothing',
      () async {
        final before = CurrencyConstants.onCurrencyChanged.value;

        await dataSource(
          () async => (currencyCode: localeCurrency, countryCode: 'ZZ'),
        ).getSettings();
        await settle();

        expect(CcAppStorage.instance.currencyCode, localeCurrency);
        expect(CcAppStorage.instance.currencyDetectionCountryCode, 'ZZ');
        expect(CurrencyConstants.onCurrencyChanged.value, before);
      },
    );

    test(
      'a timed-out GPS keeps the locale currency and broadcasts nothing',
      () async {
        final before = CurrencyConstants.onCurrencyChanged.value;
        final neverAnswers = Completer<_Gps>();

        await dataSource(() => neverAnswers.future).getSettings();
        await settle();
        neverAnswers.complete((currencyCode: gpsCurrency, countryCode: 'ZZ'));
        await settle();

        expect(CcAppStorage.instance.currencyCode, localeCurrency);
        expect(CurrencyConstants.onCurrencyChanged.value, before);
      },
    );

    test('a failing GPS detector keeps the locale currency', () async {
      final before = CurrencyConstants.onCurrencyChanged.value;

      await dataSource(() async => throw StateError('no gps')).getSettings();
      await settle();

      expect(CcAppStorage.instance.currencyCode, localeCurrency);
      expect(CurrencyConstants.onCurrencyChanged.value, before);
    });

    test(
      'never overrides a currency the user picked while GPS was running',
      () async {
        final gps = Completer<_Gps>();
        final source = dataSource(
          () => gps.future,
          timeout: const Duration(seconds: 30),
        );

        await source.getSettings();
        CcAppStorage.instance
          ..currencyCode = CurrencyConstants.eur
          ..currencySelectionSource = CurrencySelectionSources.userSelected;
        final before = CurrencyConstants.onCurrencyChanged.value;
        gps.complete((currencyCode: gpsCurrency, countryCode: 'ZZ'));
        await settle();

        expect(CcAppStorage.instance.currencyCode, CurrencyConstants.eur);
        expect(CurrencyConstants.onCurrencyChanged.value, before);
      },
    );

    test('concurrent first reads start exactly one GPS detection', () async {
      var detections = 0;
      final source = dataSource(() async {
        detections++;
        return (currencyCode: localeCurrency, countryCode: null);
      });

      await Future.wait([
        source.getSettings(),
        source.getSettings(),
        source.getSettings(),
      ]);
      await settle();

      expect(detections, 1);
    });
  });

  group('currency already stored', () {
    test('never runs GPS detection again', () async {
      CcAppStorage.instance
        ..currencyCode = CurrencyConstants.vnd
        ..currencySelectionSource = CurrencySelectionSources.userSelected;
      var detections = 0;

      final settings = await dataSource(() async {
        detections++;
        return (currencyCode: gpsCurrency, countryCode: 'ZZ');
      }).getSettings();
      await settle();

      expect(detections, 0);
      expect(settings.currencyCode, CurrencyConstants.vnd);
    });
  });
}
