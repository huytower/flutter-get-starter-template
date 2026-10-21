import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/di/di.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/liability_balance_entity.dart';
import '../entities/liability_entity.dart';
import '../repositories/liability_repository.dart';

/// Computes the outstanding balance and repaid amount for every loan.
@lazySingleton
class GetLiabilityBalancesUseCase {
  GetLiabilityBalancesUseCase(
    this._LiabilityRepository,
    this._transactionRepository,
  ) : _categoryRepository = getIt<CategoryRepository>();

  final LiabilityRepository _LiabilityRepository;
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  Future<Result<List<LiabilityBalanceEntity>, CcFailure>> call() async {
    final liabilitiesResult = await _LiabilityRepository.getLiabilities();
    if (liabilitiesResult.isError()) {
      return Error(liabilitiesResult.tryGetError()!);
    }

    final txnResult = await _transactionRepository.getListTransactions();
    if (txnResult.isError()) {
      return Error(txnResult.tryGetError()!);
    }

    final catResult = await _categoryRepository.getCategories();
    final categories = catResult.tryGetSuccess() ?? <CategoryEntity>[];

    final rawLiabilities = liabilitiesResult.tryGetSuccess()!;
    final transactions = txnResult.tryGetSuccess()!;

    Get.log(
      '[GetLiabilityBalancesUseCase] Start computing liability balances. '
      'rawLiabilities count: ${rawLiabilities.length}, total txns count: ${transactions.length}',
    );

    // Group liabilities by direction + categoryLabel (unique liability name)
    final grouped = <String, List<LiabilityEntity>>{};
    for (final l in rawLiabilities) {
      final labelKey = l.categoryLabel.trim().toLowerCase();
      final key = '${l.direction}_$labelKey';
      grouped.putIfAbsent(key, () => <LiabilityEntity>[]).add(l);
    }

    // Keep track of transaction IDs matched to explicit liability groups
    final matchedTxnIds = <String>{};

    final balances = <LiabilityBalanceEntity>[];

    for (final entry in grouped.entries) {
      final List<LiabilityEntity> items = entry.value;
      // Primary liability entity (most recently updated)
      items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final primary = items.first;

      final labelKey = primary.categoryLabel.trim().toLowerCase();
      final groupIds = items.map((e) => e.id).toSet();

      // Collect all transactions belonging to any liability in this group (strictly direction-matched)
      final groupTxns = transactions.where((t) {
        if (!t.isDebtActivity || t.isDeleted) return false;

        if (primary.isBorrow) {
          if (t.type != TransactionType.debtBorrow &&
              t.type != TransactionType.debtRepay) {
            return false;
          }
        } else {
          if (t.type != TransactionType.debtLend &&
              t.type != TransactionType.debtCollect) {
            return false;
          }
        }

        // If transaction has an explicit liabilityId, ONLY match if it belongs to this group's IDs
        if (t.liabilityId != null && t.liabilityId!.isNotEmpty) {
          return groupIds.contains(t.liabilityId);
        }

        // Fallback for transactions without liabilityId (match by category label name)
        if (t.category.trim().toLowerCase() == labelKey) {
          return true;
        }

        return false;
      }).toList();

      for (final t in groupTxns) {
        matchedTxnIds.add(t.id);
      }

      // Base principal from explicit liability records
      final basePrincipal = items.fold<int>(
        0,
        (sum, item) => sum + item.principalAmount,
      );

      int additionalPrincipal = 0;
      int totalRepaid = 0;

      for (final txn in groupTxns) {
        // Skip initial creation transaction if already counted in basePrincipal
        if (txn.id.endsWith('_init') ||
            items.any((item) => txn.id == '${item.id}_init')) {
          continue;
        }

        if (txn.type == TransactionType.debtBorrow ||
            txn.type == TransactionType.debtLend) {
          additionalPrincipal += txn.amount;
        } else if (txn.type == TransactionType.debtRepay ||
            txn.type == TransactionType.debtCollect) {
          totalRepaid += txn.amount;
        }
      }

      final totalPrincipal = basePrincipal + additionalPrincipal;
      final outstandingBalance = totalPrincipal - totalRepaid;

      final derivedRepaid = totalPrincipal - outstandingBalance;
      final finalRepaid = totalRepaid > derivedRepaid && totalRepaid > 0
          ? totalRepaid
          : (derivedRepaid > 0 ? derivedRepaid : 0);

      Get.log(
        '[GetLiabilityBalancesUseCase] Group "${entry.key}": '
        'basePrincipal=$basePrincipal, additionalPrincipal=$additionalPrincipal, '
        'totalPrincipal=$totalPrincipal, totalRepaid=$totalRepaid, finalRepaid=$finalRepaid, '
        'outstandingBalance=$outstandingBalance, matchedTxns=${groupTxns.length}',
      );

      final cat = categories.firstWhereOrNull(
        (c) => c.id == primary.categoryId,
      );

      final combinedEntity = primary.copyWith(
        principalAmount: totalPrincipal,
        categoryNameKey: cat?.nameKey,
      );

      final balance = LiabilityBalanceEntity(
        liability: combinedEntity,
        outstandingBalance: outstandingBalance,
        repaidAmount: finalRepaid,
      );

      balances.add(balance);
    }

    // Handle unmatched/orphaned debt transactions
    final unmatchedDebtTxns = transactions.where((t) {
      if (!t.isDebtActivity || t.isDeleted) return false;
      return !matchedTxnIds.contains(t.id);
    }).toList();

    if (unmatchedDebtTxns.isNotEmpty) {
      Get.log(
        '[GetLiabilityBalancesUseCase] Found ${unmatchedDebtTxns.length} unmatched debt transactions. Creating synthetic liability groups.',
      );

      final orphanGrouped = <String, List<TransactionEntity>>{};
      for (final t in unmatchedDebtTxns) {
        final direction =
            (t.type == TransactionType.debtBorrow ||
                t.type == TransactionType.debtRepay)
            ? LiabilityDirection.borrow
            : LiabilityDirection.lend;
        final labelKey = t.category.trim().toLowerCase();
        final key = '${direction}_$labelKey';
        orphanGrouped.putIfAbsent(key, () => []).add(t);
      }

      for (final entry in orphanGrouped.entries) {
        final txns = entry.value;
        txns.sort((a, b) => b.date.compareTo(a.date));
        final firstTxn = txns.first;

        final direction =
            (firstTxn.type == TransactionType.debtBorrow ||
                firstTxn.type == TransactionType.debtRepay)
            ? LiabilityDirection.borrow
            : LiabilityDirection.lend;

        int totalPrincipal = 0;
        int totalRepaid = 0;

        for (final t in txns) {
          if (t.type == TransactionType.debtBorrow ||
              t.type == TransactionType.debtLend) {
            totalPrincipal += t.amount;
          } else if (t.type == TransactionType.debtRepay ||
              t.type == TransactionType.debtCollect) {
            totalRepaid += t.amount;
          }
        }

        final outstandingBalance = totalPrincipal - totalRepaid;
        final derivedRepaid = totalPrincipal - outstandingBalance;
        final finalRepaid = totalRepaid > derivedRepaid && totalRepaid > 0
            ? totalRepaid
            : (derivedRepaid > 0 ? derivedRepaid : 0);

        Get.log(
          '[GetLiabilityBalancesUseCase] Synthetic Group "${entry.key}": '
          'totalPrincipal=$totalPrincipal, totalRepaid=$totalRepaid, finalRepaid=$finalRepaid, '
          'outstandingBalance=$outstandingBalance, txnsCount=${txns.length}',
        );

        final cat = categories.firstWhereOrNull(
          (c) => c.id == firstTxn.categoryId || c.nameKey == firstTxn.category,
        );

        final syntheticEntity = LiabilityEntity(
          id: firstTxn.liabilityId ?? 'synthetic_${entry.key}',
          direction: direction,
          principalAmount: totalPrincipal,
          categoryId: firstTxn.categoryId,
          categoryLabel: firstTxn.category,
          categoryNameKey: cat?.nameKey,
          categoryIconCode: firstTxn.categoryIconCode,
          categoryIconFamily: firstTxn.categoryIconFamily,
          walletId: firstTxn.walletId,
          repaymentMethod: LiabilityRepaymentMethod.lumpSum,
          createdAt: firstTxn.date,
          updatedAt: firstTxn.date,
          currencyCode: firstTxn.currencyCode,
        );

        balances.add(
          LiabilityBalanceEntity(
            liability: syntheticEntity,
            outstandingBalance: outstandingBalance,
            repaidAmount: finalRepaid,
          ),
        );
      }
    }

    balances.sort(
      (a, b) => b.liability.updatedAt.compareTo(a.liability.updatedAt),
    );

    Get.log(
      '[GetLiabilityBalancesUseCase] Computed total ${balances.length} liability balance entries.',
    );

    return Success(balances);
  }
}
