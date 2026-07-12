import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../entities/financial_runway_entity.dart';

@lazySingleton
class GetFinancialRunwayUseCase {
  GetFinancialRunwayUseCase(
    this._walletRepository,
    this._transactionRepository,
  );

  final WalletRepository _walletRepository;
  final TransactionRepository _transactionRepository;

  Future<Result<FinancialRunwayEntity, CcFailure>> call() async {
    // 1. Get total balance
    final walletResult = await _walletRepository.getWallets();
    if (walletResult.isError()) {
      return Error(walletResult.tryGetError()!);
    }
    final totalBalance = walletResult
        .tryGetSuccess()!
        .fold<double>(0, (sum, wallet) => sum + wallet.balance);

    // 2. Get average expense from last 3 months + current month to be real-time
    final now = DateTime.now();
    // Start of 3 full months ago + current month (Total ~4 months window)
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
    final totalExpenses = transactions
        .where((t) => t.type == 'expense')
        .fold<double>(0, (sum, t) => sum + t.amount);

    // Calculate how many months of data we actually have
    double monthsCount = 1; // Default to 1 to avoid division by zero
    if (transactions.isNotEmpty) {
      final earliestTxn = transactions
          .map((t) => t.date)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      
      // Calculate months between earliestTxn and today
      final diffMonths = (now.year - earliestTxn.year) * 12 + 
                         (now.month - earliestTxn.month) + 1;
      
      monthsCount = diffMonths.toDouble();
      if (monthsCount > 4) monthsCount = 4;
      if (monthsCount < 1) monthsCount = 1;
    }

    final averageMonthlyExpense = totalExpenses / monthsCount;

    if (averageMonthlyExpense <= 0) {
      return Success(FinancialRunwayEntity(
        months: 0,
        days: 0,
        message: CcLocaleKeys.report_runway_insufficient,
        totalBalance: totalBalance,
        averageMonthlyExpense: 0,
        status: FinancialRunwayStatus.insufficient,
      ));
    }

    if (totalBalance <= 0) {
      return Success(FinancialRunwayEntity(
        months: 0,
        days: 0,
        message: CcLocaleKeys.report_runway_caution,
        totalBalance: totalBalance,
        averageMonthlyExpense: averageMonthlyExpense,
        status: FinancialRunwayStatus.caution,
      ));
    }

    final totalMonths = totalBalance / averageMonthlyExpense;
    final months = totalMonths.floor();
    final remainingFraction = totalMonths - months;
    final days = (remainingFraction * 30).round();

    String messageKey;
    FinancialRunwayStatus status = FinancialRunwayStatus.caution;
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

    return Success(FinancialRunwayEntity(
      months: months,
      days: days,
      message: messageKey,
      totalBalance: totalBalance,
      averageMonthlyExpense: averageMonthlyExpense,
      status: status,
    ));
  }
}
