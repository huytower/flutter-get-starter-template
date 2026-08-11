import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../budget_limit/domain/repositories/budget_limit_repository.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
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
    this._budgetLimitRepository,
  );

  final WalletRepository _walletRepository;
  final TransactionRepository _transactionRepository;
  final GetWalletBalancesUseCase _getWalletBalances;
  final CategoryRepository _categoryRepository;
  final BudgetLimitRepository _budgetLimitRepository;

  /// Sums the monthly limits of all active fixed-price budgets. These are the
  /// recurring mandatory costs (e.g. rent, electricity) the user has marked
  /// with the fixed-price (bolt) flag in the budget limit feature.
  Future<double> _getFixedMonthlyCost() async {
    final result = await _budgetLimitRepository.getBudgets(activeOnly: true);
    if (result.isError()) return 0;
    return result
        .tryGetSuccess()!
        .where((b) => b.isFixedPrice)
        .fold<double>(0, (sum, b) => sum + b.limit);
  }

  Future<Result<FinancialRunwayEntity, CcFailure>> call() async {
    // 1. Get total balance (Book Balance) — liquid wallets + Quỹ dự phòng
    // and any other non-investment wallet. Investment positions are excluded
    // per spec: they're capital tied up in an asset, not available runway.
    final balancesResult = await _getWalletBalances.call();
    if (balancesResult.isError()) {
      return Error(balancesResult.tryGetError()!);
    }
    final totalBalance = balancesResult
        .tryGetSuccess()!
        .where((b) => b.wallet.type != WalletType.investment)
        .fold<double>(0, (sum, b) => sum + b.bookBalance);

    // 2. Get categories to identify survival expenses
    final categoriesResult = await _categoryRepository.getCategories();
    if (categoriesResult.isError()) {
      return Error(categoriesResult.tryGetError()!);
    }

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

    // 4. Recurring mandatory cost: sum of fixed-price budget limits.
    final fixedMonthlyCost = await _getFixedMonthlyCost();

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

    // According to Business Requirements, Runway is based on Average Monthly
    // Expenses. When fixed-price budgets are set, they represent the mandatory
    // recurring burn, so we prefer that over the historical lifestyle average.
    final averageMonthlyExpense = totalExpenses / monthsCount;
    final monthlyBurn = fixedMonthlyCost > 0
        ? fixedMonthlyCost
        : averageMonthlyExpense;

    if (monthlyBurn <= 0) {
      return Success(
        FinancialRunwayEntity(
          months: 0,
          days: 0,
          message: CcLocaleKeys.report_runway_insufficient,
          totalBalance: totalBalance,
          averageMonthlyExpense: averageMonthlyExpense,
          fixedMonthlyCost: fixedMonthlyCost,
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
          fixedMonthlyCost: fixedMonthlyCost,
          status: FinancialRunwayStatus.caution,
        ),
      );
    }

    final totalMonths = totalBalance / monthlyBurn;
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
        fixedMonthlyCost: fixedMonthlyCost,
        status: status,
      ),
    );
  }
}
