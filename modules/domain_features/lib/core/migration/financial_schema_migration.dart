import 'package:app_config/data/datasource/local/box/app_storage/cc_app_storage.dart';
import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../features/budget_limit/data/models/budget_limit_model.dart';
import '../../features/liability/data/models/liability_model.dart';
import '../../features/reconciliation/data/models/reconciliation_model.dart';
import '../../features/transaction/data/models/transaction_model.dart';
import '../../features/wallet/data/models/wallet_hive_model.dart';
import '../constant/currency_constants.dart';

class CurrencyAnnotationResult {
  const CurrencyAnnotationResult({
    required this.walletsUpdated,
    required this.transactionsUpdated,
    required this.budgetsUpdated,
    required this.liabilitiesUpdated,
    required this.reconciliationsUpdated,
    required this.success,
    this.errorMessage,
  });

  final int walletsUpdated;
  final int transactionsUpdated;
  final int budgetsUpdated;
  final int liabilitiesUpdated;
  final int reconciliationsUpdated;
  final bool success;
  final String? errorMessage;
}

/// Versioned schema migration runner for annotating existing financial records
/// with their original record currencyCode (defaulting to VND for legacy records).
/// Fail-secure: version does not advance on partial or full failure, ensuring safe retries on next startup.
abstract final class FinancialSchema {
  static const currentVersion = 2;

  static Future<CurrencyAnnotationResult> runMigrationIfNeeded() async {
    final s = CcAppStorage.instance;
    final storedVersion = s.financialSchemaVersion ?? 1;

    if (storedVersion >= currentVersion) {
      return const CurrencyAnnotationResult(
        walletsUpdated: 0,
        transactionsUpdated: 0,
        budgetsUpdated: 0,
        liabilitiesUpdated: 0,
        reconciliationsUpdated: 0,
        success: true,
      );
    }

    int walletsUpdated = 0;
    int transactionsUpdated = 0;
    int budgetsUpdated = 0;
    int liabilitiesUpdated = 0;
    int reconciliationsUpdated = 0;

    try {
      // 1. Wallets
      if (Hive.isBoxOpen(CcHiveBox.WALLET_BOX_NAME) ||
          await Hive.boxExists(CcHiveBox.WALLET_BOX_NAME)) {
        final box = Hive.isBoxOpen(CcHiveBox.WALLET_BOX_NAME)
            ? Hive.box<WalletHiveModel>(CcHiveBox.WALLET_BOX_NAME)
            : await Hive.openBox<WalletHiveModel>(CcHiveBox.WALLET_BOX_NAME);

        for (final key in box.keys) {
          final wallet = box.get(key);
          if (wallet != null) {
            final normalizedCode = CurrencyConstants.validateCurrencyCode(
              wallet.currencyCode,
            );
            if (wallet.currencyCode == null ||
                wallet.currencyCode != normalizedCode) {
              final annotated = WalletHiveModel(
                id: wallet.id,
                name: wallet.name,
                balance: wallet.balance,
                iconCode: wallet.iconCode,
                type: wallet.type,
                createdAt: wallet.createdAt,
                remoteId: wallet.remoteId,
                syncStatus: wallet.syncStatus,
                lastSyncedAt: wallet.lastSyncedAt,
                lastModifiedAt: wallet.lastModifiedAt,
                categoryId: wallet.categoryId,
                displayOrder: wallet.displayOrder,
                currencyCode: normalizedCode,
              );
              await box.put(key, annotated);
              walletsUpdated++;
            }
          }
        }
      }

      // 2. Transactions
      if (Hive.isBoxOpen(CcHiveBox.TRANSACTION_BOX_NAME) ||
          await Hive.boxExists(CcHiveBox.TRANSACTION_BOX_NAME)) {
        final box = Hive.isBoxOpen(CcHiveBox.TRANSACTION_BOX_NAME)
            ? Hive.box<TransactionModel>(CcHiveBox.TRANSACTION_BOX_NAME)
            : await Hive.openBox<TransactionModel>(
                CcHiveBox.TRANSACTION_BOX_NAME,
              );

        for (final key in box.keys) {
          final tx = box.get(key);
          if (tx != null) {
            final normalizedCode = CurrencyConstants.validateCurrencyCode(
              tx.currencyCode,
            );
            if (tx.currencyCode == null || tx.currencyCode != normalizedCode) {
              final annotated = tx.copyWith(currencyCode: normalizedCode);
              await box.put(key, annotated);
              transactionsUpdated++;
            }
          }
        }
      }

      // 3. Budgets
      if (Hive.isBoxOpen(CcHiveBox.BUDGET_BOX_NAME) ||
          await Hive.boxExists(CcHiveBox.BUDGET_BOX_NAME)) {
        final box = Hive.isBoxOpen(CcHiveBox.BUDGET_BOX_NAME)
            ? Hive.box<BudgetLimitModel>(CcHiveBox.BUDGET_BOX_NAME)
            : await Hive.openBox<BudgetLimitModel>(CcHiveBox.BUDGET_BOX_NAME);

        for (final key in box.keys) {
          final budget = box.get(key);
          if (budget != null) {
            final normalizedCode = CurrencyConstants.validateCurrencyCode(
              budget.currencyCode,
            );
            if (budget.currencyCode == null ||
                budget.currencyCode != normalizedCode) {
              final annotated = BudgetLimitModel(
                id: budget.id,
                categoryId: budget.categoryId,
                name: budget.name,
                limit: budget.limit,
                order: budget.order,
                isClosed: budget.isClosed,
                isFixedPrice: budget.isFixedPrice,
                remoteId: budget.remoteId,
                syncStatus: budget.syncStatus,
                lastSyncedAt: budget.lastSyncedAt,
                lastModifiedAt: budget.lastModifiedAt,
                currencyCode: normalizedCode,
              );
              await box.put(key, annotated);
              budgetsUpdated++;
            }
          }
        }
      }

      // 4. Liabilities
      if (Hive.isBoxOpen(CcHiveBox.LIABILITY_BOX_NAME) ||
          await Hive.boxExists(CcHiveBox.LIABILITY_BOX_NAME)) {
        final box = Hive.isBoxOpen(CcHiveBox.LIABILITY_BOX_NAME)
            ? Hive.box<LiabilityModel>(CcHiveBox.LIABILITY_BOX_NAME)
            : await Hive.openBox<LiabilityModel>(CcHiveBox.LIABILITY_BOX_NAME);

        for (final key in box.keys) {
          final lib = box.get(key);
          if (lib != null) {
            final normalizedCode = CurrencyConstants.validateCurrencyCode(
              lib.currencyCode,
            );
            if (lib.currencyCode == null ||
                lib.currencyCode != normalizedCode) {
              final annotated = LiabilityModel(
                id: lib.id,
                direction: lib.direction,
                principalAmount: lib.principalAmount,
                categoryId: lib.categoryId,
                categoryLabel: lib.categoryLabel,
                categoryIconCode: lib.categoryIconCode,
                categoryIconFamily: lib.categoryIconFamily,
                walletId: lib.walletId,
                repaymentMethod: lib.repaymentMethod,
                installments: lib.installments,
                finalDueDate: lib.finalDueDate,
                note: lib.note,
                createdAt: lib.createdAt,
                remoteId: lib.remoteId,
                syncStatus: lib.syncStatus,
                lastSyncedAt: lib.lastSyncedAt,
                lastModifiedAt: lib.lastModifiedAt,
                reminderBeforeDueDate: lib.reminderBeforeDueDate,
                currencyCode: normalizedCode,
              );
              await box.put(key, annotated);
              liabilitiesUpdated++;
            }
          }
        }
      }

      // 5. Reconciliations
      if (Hive.isBoxOpen(CcHiveBox.RECONCILIATION_BOX_NAME) ||
          await Hive.boxExists(CcHiveBox.RECONCILIATION_BOX_NAME)) {
        final box = Hive.isBoxOpen(CcHiveBox.RECONCILIATION_BOX_NAME)
            ? Hive.box<ReconciliationModel>(CcHiveBox.RECONCILIATION_BOX_NAME)
            : await Hive.openBox<ReconciliationModel>(
                CcHiveBox.RECONCILIATION_BOX_NAME,
              );

        for (final key in box.keys) {
          final rec = box.get(key);
          if (rec != null) {
            final normalizedCode = CurrencyConstants.validateCurrencyCode(
              rec.currencyCode,
            );
            if (rec.currencyCode == null ||
                rec.currencyCode != normalizedCode) {
              final annotated = ReconciliationModel(
                id: rec.id,
                year: rec.year,
                week: rec.week,
                systemTotal: rec.systemTotal,
                actualTotal: rec.actualTotal,
                difference: rec.difference,
                date: rec.date,
                adjustmentTransactionIds: rec.adjustmentTransactionIds,
                allocations: rec.allocations,
                remoteId: rec.remoteId,
                syncStatus: rec.syncStatus,
                lastSyncedAt: rec.lastSyncedAt,
                lastModifiedAt: rec.lastModifiedAt,
                currencyCode: normalizedCode,
              );
              await box.put(key, annotated);
              reconciliationsUpdated++;
            }
          }
        }
      }

      // Only advance version after ALL box migrations succeed completely
      s.financialSchemaVersion = currentVersion;
      await s.save();

      return CurrencyAnnotationResult(
        walletsUpdated: walletsUpdated,
        transactionsUpdated: transactionsUpdated,
        budgetsUpdated: budgetsUpdated,
        liabilitiesUpdated: liabilitiesUpdated,
        reconciliationsUpdated: reconciliationsUpdated,
        success: true,
      );
    } catch (e) {
      debugPrint(
        '[FinancialSchema] Migration failed at version $currentVersion: $e',
      );
      return CurrencyAnnotationResult(
        walletsUpdated: walletsUpdated,
        transactionsUpdated: transactionsUpdated,
        budgetsUpdated: budgetsUpdated,
        liabilitiesUpdated: liabilitiesUpdated,
        reconciliationsUpdated: reconciliationsUpdated,
        success: false,
        errorMessage: e.toString(),
      );
    }
  }
}
