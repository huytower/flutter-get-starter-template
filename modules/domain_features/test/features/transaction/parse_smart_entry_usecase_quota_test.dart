import 'dart:typed_data';

import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:domain_features/core/exchange_rates/currency_conversion_service.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_types.dart';
import 'package:domain_features/core/helper/ai_fallback_preference_datasource.dart';
import 'package:domain_features/features/category/domain/entities/category_entity.dart';
import 'package:domain_features/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:domain_features/features/transaction/domain/entities/smart_entry_input.dart';
import 'package:domain_features/features/transaction/domain/usecases/parse_smart_entry_usecase.dart';
import 'package:domain_features/features/wallet/domain/entities/wallet_entity.dart';
import 'package:domain_features/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StubGetCategories implements GetCategoriesUseCase {
  _StubGetCategories(this.categories);

  final List<CategoryEntity> categories;

  @override
  Future<Result<List<CategoryEntity>, CcFailure>> call() async =>
      Success(categories);
}

class _StubWalletRepository implements WalletRepository {
  @override
  Future<Result<List<WalletEntity>, CcFailure>> getWallets() async =>
      const Success([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedRateRepository implements ExchangeRateRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _food = CategoryEntity(
  id: 'food',
  nameKey: 'food',
  iconCode: 0,
  groupId: 'g1',
);

const _text = SmartEntryTextInput('cafe 30k');

ParseSmartEntryUseCase _useCase(List<CategoryEntity> categories) =>
    ParseSmartEntryUseCase(
      _StubGetCategories(categories),
      CurrencyConversionService(_UnusedRateRepository()),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AiFallbackPreferenceDataSource prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = AiFallbackPreferenceDataSource();
    await getIt.reset();
    getIt.registerSingleton<AiFallbackPreferenceDataSource>(prefs);
    getIt.registerSingleton<WalletRepository>(_StubWalletRepository());
  });

  tearDown(() => getIt.reset());

  String? failureOf(Result<Object?, CcFailure> result) =>
      result.tryGetError()?.message;

  group('ParseSmartEntryUseCase quota', () {
    test('fails with gemini_disabled and spends nothing when off', () async {
      await prefs.setGeminiEnabled(false);

      final result = await _useCase([_food]).call(input: _text);

      expect(failureOf(result), ParseSmartEntryUseCase.geminiDisabledReason);
      expect(await prefs.getTodayFallbackCount(), 0);
    });

    test('fails with daily_limit_reached once the cap is used up', () async {
      for (var i = 0; i < AiFallbackPreferenceDataSource.dailyCallLimit; i++) {
        await prefs.incrementTodayFallbackCount();
      }

      final result = await _useCase([_food]).call(input: _text);

      expect(failureOf(result), ParseSmartEntryUseCase.dailyLimitReachedReason);
      expect(
        await prefs.getTodayFallbackCount(),
        AiFallbackPreferenceDataSource.dailyCallLimit,
      );
    });

    test('does not spend a call when there are no categories', () async {
      final result = await _useCase(const []).call(input: _text);

      expect(failureOf(result), 'no_categories');
      expect(await prefs.getTodayFallbackCount(), 0);
    });

    test('does not spend a call when no image was given', () async {
      final result = await _useCase([
        _food,
      ]).call(input: const SmartEntryImagesInput([]));

      expect(failureOf(result), 'no_input');
      expect(await prefs.getTodayFallbackCount(), 0);
    });

    test('spends exactly one call once the request goes out', () async {
      final result = await _useCase([_food]).call(
        input: SmartEntryImagesInput([
          (bytes: Uint8List(1), mimeType: 'image/jpeg'),
        ]),
      );

      expect(
        failureOf(result),
        isNot(ParseSmartEntryUseCase.dailyLimitReachedReason),
      );
      expect(await prefs.getTodayFallbackCount(), 1);
    });
  });
}
