import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:domain_features/core/presentation/helper/transaction_form_helpers.dart';

/// Turns quick-amount suggestions into `CcQuickValue`s labelled the app's way
/// (short form with the currency symbol, e.g. `50K ₫`), for
/// `CcQuickValueChips` and `CcKeypadPanel`.
abstract final class QuickAmountValues {
  /// [amounts] labelled in [currencyCode] (defaults to the primary currency).
  static List<CcQuickValue<int>> from(
    List<int> amounts, {
    String? currencyCode,
  }) {
    final code = currencyCode ?? CurrencyConstants.currentPrimaryCurrency;
    return [
      for (final amount in amounts)
        CcQuickValue(
          value: amount,
          label: TransactionFormHelpers.formatShortWithSymbol(
            amount,
            currencyCode: code,
          ),
        ),
    ];
  }
}
