import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../category/domain/repositories/category_repository.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../../wallet/domain/usecases/get_wallet_balances_usecase.dart';
import '../entities/financial_runway_entity.dart';

@lazySingleton
class GetFinancialRunwayUseCase {
  GetFinancialRunwayUseCase(
    this._walletRepository,
    this._transactionRepository,
    this._getWalletBalances,
    this._categoryRepository,
  );

  final WalletRepository _walletRepository;
  final TransactionRepository _transactionRepository;
  final GetWalletBalancesUseCase _getWalletBalances;
  final CategoryRepository _categoryRepository;

  /// Survival groups as defined in BUSINESS_REQUIREMENT.md & PrjColors
  /// 1: Food, 2: Transport, 3: Utilities, 4: Housing, 5: Health, 9: Debt, 10: Insurance
  static const Set<String> survivalGroups = {
    'group_1',
    'group_2',
    'group_3',
    'group_4',
    'group_5',
    'group_9',
    'group_10',
  };

  Future<Result<FinancialRunwayEntity, CcFailure>> call() async {
    // 1. Get total balance (Book Balance)
    // In LV3, we might filter out WalletType.investment here.
    final balancesResult = await _getWalletBalances.call();
    if (balancesResult.isError()) {
      return Error(balancesResult.tryGetError()!);
    }
    final totalBalance = balancesResult.tryGetSuccess()!.fold<double>(
      0,
      (sum, b) => sum + b.bookBalance,
    );

    // 2. Get categories to identify survival expenses
    final categoriesResult = await _categoryRepository.getCategories();
    if (categoriesResult.isError()) {
      return Error(categoriesResult.tryGetError()!);
    }
    final survivalCategoryIds = categoriesResult
        .tryGetSuccess()!
        .where((c) => survivalGroups.contains(c.groupId))
        .map((c) => c.id)
        .toSet();

    // 3. Get average expense from last 3 months + current month
    final now = DateTime.now();
    final startOfPeriod = DateTime(now.year, now.month - 3, 1);
    final endOfPeriod = now;

    final txnResult = await _transactionRepository.getTransactionsByPeriod(
      startOfPeriod,
      endOfPeriod,
    );

    if (txnResult.isError()) {
      return Error(txnResult.tryGetError()!);
    }

    final transactions = txnResult.tryGetSuccess()!;
    final expenseTransactions = transactions.where(
      (t) => t.type == TransactionType.expense,
    );

    final totalExpenses = expenseTransactions.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );

    // Filter survival expenses (essential for the "Safety Index")
    // ignore: unused_local_variable
    final survivalExpenses = expenseTransactions
        .where((t) => survivalCategoryIds.contains(t.categoryId))
        .fold<double>(0, (sum, t) => sum + t.amount);

    // Calculate how many months of data we actually have
    double monthsCount = 1;
    if (transactions.isNotEmpty) {
      final earliestTxn = transactions
          .map((t) => t.date)
          .reduce((a, b) => a.isBefore(b) ? a : b);

      final diffMonths =
          (now.year - earliestTxn.year) * 12 +
          (now.month - earliestTxn.month) +
          1;

      monthsCount = diffMonths.toDouble();
      if (monthsCount > 4) monthsCount = 4;
      if (monthsCount < 1) monthsCount = 1;
    }

    // According to Business Requirements, Runway is based on Average Monthly Expenses.
    // We use totalExpenses here as the primary "Lifestyle Runway".
    final averageMonthlyExpense = totalExpenses / monthsCount;

    // Optional: Calculate survival-based average for a more accurate "Safety Index"
    // final averageSurvivalExpense = survivalExpenses / monthsCount;

    if (averageMonthlyExpense <= 0) {
      return Success(
        FinancialRunwayEntity(
          months: 0,
          days: 0,
          message: CcLocaleKeys.report_runway_insufficient,
          totalBalance: totalBalance,
          averageMonthlyExpense: 0,
          status: FinancialRunwayStatus.insufficient,
        ),
      );
    }

    if (totalBalance <= 0) {
      return Success(
        FinancialRunwayEntity(
          months: 0,
          days: 0,
          message: CcLocaleKeys.report_runway_caution,
          totalBalance: totalBalance,
          averageMonthlyExpense: averageMonthlyExpense,
          status: FinancialRunwayStatus.caution,
        ),
      );
    }

    final totalMonths = totalBalance / averageMonthlyExpense;
    final months = totalMonths.floor();
    final remainingFraction = totalMonths - months;
    final days = (remainingFraction * 30).round();

    String messageKey;
    FinancialRunwayStatus status = FinancialRunwayStatus.caution;

    // Aligned with report_runway_* keys in CcLocaleKeys
    if (months >= 12) {
      messageKey = CcLocaleKeys.report_runway_very_good;
      status = FinancialRunwayStatus.excellent;
    } else if (months >= 6) {
      messageKey = CcLocaleKeys.report_runway_good;
      status = FinancialRunwayStatus.good;
    } else if (months >= 3) {
      messageKey = CcLocaleKeys.report_runway_safe;
      status = FinancialRunwayStatus.safe;
    } else {
      messageKey = CcLocaleKeys.report_runway_caution;
      status = FinancialRunwayStatus.caution;
    }

    return Success(
      FinancialRunwayEntity(
        months: months,
        days: days,
        message: messageKey,
        totalBalance: totalBalance,
        averageMonthlyExpense: averageMonthlyExpense,
        status: status,
      ),
    );
  }
}
