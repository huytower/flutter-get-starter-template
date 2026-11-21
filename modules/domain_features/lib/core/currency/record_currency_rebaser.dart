import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/currency/currency_rebase.dart';
import 'package:domain_features/core/domain/entities/liability_entity.dart';
import 'package:domain_features/core/exchange_rates/currency_conversion_service.dart';
import 'package:domain_features/features/budget_limit/domain/entities/budget_limit_entity.dart';
import 'package:domain_features/features/budget_limit/domain/repositories/budget_limit_repository.dart';
import 'package:domain_features/features/liability/domain/repositories/liability_repository.dart';
import 'package:domain_features/features/reconciliation/domain/entities/reconciliation_allocation_entity.dart';
import 'package:domain_features/features/reconciliation/domain/entities/reconciliation_entity.dart';
import 'package:domain_features/features/reconciliation/domain/repositories/reconciliation_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

/// Converts the records that carry amounts outside wallets and transactions
/// (liabilities, budgets, reconciliations) into one currency.
///
/// Part of `BookCurrencyAligner`; all or nothing like it.
@injectable
class RecordCurrencyRebaser {
  RecordCurrencyRebaser(
    this._liabilities,
    this._budgets,
    this._reconciliations,
    this._conversion,
  );

  final LiabilityRepository _liabilities;
  final BudgetLimitRepository _budgets;
  final ReconciliationRepository _reconciliations;
  final CurrencyConversionService _conversion;

  /// Converts every liability, budget and reconciliation not in [target];
  /// returns how many records changed.
  Future<Result<int, CcFailure>> alignTo(String target) async {
    final rebase = CurrencyRebase(_conversion, target);

    final liabilitiesResult = await _liabilities.getLiabilities();
    final budgetsResult = await _budgets.getBudgets(activeOnly: false);
    final reconciliationsResult = await _reconciliations.getReconciliations();
    for (final r in [liabilitiesResult, budgetsResult, reconciliationsResult]) {
      if (r.isError()) return Error(r.tryGetError()!);
    }

    final liabilities = <LiabilityEntity>[
      for (final l in liabilitiesResult.tryGetSuccess()!)
        if (rebase.needs(l.currencyCode)) await _liability(l, rebase),
    ];
    final budgets = <BudgetLimitEntity>[
      for (final b in budgetsResult.tryGetSuccess()!)
        if (rebase.needs(b.currencyCode))
          b.copyWith(
            limit: await rebase.convert(b.limit, b.currencyCode),
            currencyCode: target,
          ),
    ];
    final reconciliations = <ReconciliationEntity>[
      for (final r in reconciliationsResult.tryGetSuccess()!)
        if (rebase.needs(r.currencyCode)) await _reconciliation(r, rebase),
    ];
    if (rebase.failed) {
      return Error(ValidationFailure('No exchange rate into $target'));
    }

    for (final l in liabilities) {
      final saved = await _liabilities.updateLiability(l);
      if (saved.isError()) return Error(saved.tryGetError()!);
    }
    for (final b in budgets) {
      final saved = await _budgets.updateBudget(b);
      if (saved.isError()) return Error(saved.tryGetError()!);
    }
    for (final r in reconciliations) {
      final saved = await _reconciliations.saveReconciliation(r);
      if (saved.isError()) return Error(saved.tryGetError()!);
    }
    return Success(
      liabilities.length + budgets.length + reconciliations.length,
    );
  }

  Future<LiabilityEntity> _liability(
    LiabilityEntity l,
    CurrencyRebase rebase,
  ) async {
    final from = l.currencyCode;
    final installments = l.installments == null
        ? null
        : [
            for (final i in l.installments!)
              LiabilityInstallmentEntity(
                dueDate: i.dueDate,
                amount: await rebase.convert(i.amount, from),
              ),
          ];
    return l.copyWith(
      principalAmount: await rebase.convert(l.principalAmount, from),
      installments: installments,
      currencyCode: rebase.target,
    );
  }

  Future<ReconciliationEntity> _reconciliation(
    ReconciliationEntity r,
    CurrencyRebase rebase,
  ) async {
    final from = r.currencyCode;
    final systemTotal = await rebase.convert(r.systemTotal, from);
    final actualTotal = await rebase.convert(r.actualTotal, from);
    return ReconciliationEntity(
      id: r.id,
      year: r.year,
      week: r.week,
      systemTotal: systemTotal,
      actualTotal: actualTotal,
      difference: actualTotal - systemTotal,
      allocations: [
        for (final a in r.allocations)
          ReconciliationAllocationEntity(
            walletId: a.walletId,
            walletName: a.walletName,
            bookBalance: await rebase.convert(a.bookBalance, from),
            actualBalance: await rebase.convert(a.actualBalance, from),
          ),
      ],
      adjustmentTransactionIds: r.adjustmentTransactionIds,
      date: r.date,
      currencyCode: rebase.target,
    );
  }
}
