import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:domain_features/core/contracts/financial_refresh_provider.dart';
import 'package:domain_features/core/currency/book_currency_aligner.dart';
import 'package:domain_features/features/profile/domain/usecases/get_profile_settings_usecase.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../contracts/book_currency_provider.dart';

@LazySingleton(as: BookCurrencyProvider)
class BookCurrencyProviderImpl implements BookCurrencyProvider {
  BookCurrencyProviderImpl(this._aligner, this._refresh, this._getSettings);

  final BookCurrencyAligner _aligner;
  final FinancialRefreshProvider _refresh;

  /// Reads the primary currency the user settled on; on a first launch it
  /// also stores the detected one, so this never aligns to a fallback.
  final GetProfileSettingsUseCase _getSettings;

  Worker? _onCurrencyChanged;

  /// Runs one alignment at a time, in order.
  Future<void> _queue = Future.value();

  @override
  Future<void> keepAlignedWithPrimary() {
    _onCurrencyChanged ??= ever(
      CurrencyConstants.onCurrencyChanged,
      (_) => _align(),
    );
    return _align();
  }

  Future<void> _align() => _queue = _queue.then((_) => _run());

  Future<void> _run() async {
    final target = (await _getSettings()).currencyCode;
    final result = await _aligner.alignTo(target);
    await result.when((changed) async {
      if (!changed) return;
      '[BookCurrency] Book converted to $target'.Log('BookCurrency');
      // Screens loaded meanwhile still hold the old amounts.
      await _refresh.refreshAllLoaded();
    }, (failure) async {
      '[BookCurrency] Not converted to $target: ${failure.message}'.Log(
        'BookCurrency',
      );
    });
  }
}
