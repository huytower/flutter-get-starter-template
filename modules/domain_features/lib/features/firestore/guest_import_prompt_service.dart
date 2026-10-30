import 'dart:async';

import 'package:app_config/data/datasource/local/box/app_storage/cc_app_storage.dart';
import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../core/di/di.dart';
import '../budget_limit/data/models/budget_limit_model.dart';
import '../category/data/datasources/local/category_seed.dart';
import '../category/data/models/category_model.dart';
import '../liability/data/models/liability_model.dart';
import '../profile/presentation/widgets/guest_import_prompt_sheet.dart';
import '../reconciliation/data/models/reconciliation_model.dart';
import '../transaction/data/models/transaction_model.dart';
import '../wallet/data/models/wallet_hive_model.dart';

enum GuestImportPrompt { atTen, finalWarning }

@lazySingleton
class GuestImportPromptService {
  static const int _firstPromptThreshold = 7;
  static const int _finalPromptThreshold = 15;

  final SessionContract _session;
  bool _promptInFlight = false;

  GuestImportPromptService(this._session);

  Future<int> countFinancialRecords() async {
    final counts = await Future.wait([
      _count<WalletHiveModel>(CcHiveBox.WALLET_BOX_NAME),
      _count<TransactionModel>(CcHiveBox.TRANSACTION_BOX_NAME),
      _count<BudgetLimitModel>(CcHiveBox.BUDGET_BOX_NAME),
      _count<LiabilityModel>(CcHiveBox.LIABILITY_BOX_NAME),
      _count<CategoryModel>(CcHiveBox.CATEGORY_BOX_NAME),
      _count<ReconciliationModel>(CcHiveBox.RECONCILIATION_BOX_NAME),
    ]);
    final total = counts.fold<int>(0, (int total, int count) => total + count);
    '[GuestImportPrompt] 📊 Financial records counted: total=$total (wallets=${counts[0]}, txns=${counts[1]}, budgets=${counts[2]}, liabilities=${counts[3]}, categories=${counts[4]}, reconciliations=${counts[5]})'
        .Log('GuestImportPromptService');
    return total;
  }

  Future<GuestImportPrompt?> evaluate() async {
    if (_promptInFlight) return null;
    final uid = _session.currentUser?.id;
    if (uid == null) return null;

    final storage = CcAppStorage.instance;
    if (storage.guestImportPromptSessionUid != uid) {
      storage.guestImportPromptSessionUid = uid;
      storage.guestImportPrompt10Shown = false;
      storage.guestImportPrompt20Dismissed = false;
      await storage.save();
    }

    if (storage.guestImportPrompt20Dismissed == true) return null;
    final count = await countFinancialRecords();
    GuestImportPrompt? result;
    if (count >= _finalPromptThreshold) {
      result = GuestImportPrompt.finalWarning;
    } else if (count >= _firstPromptThreshold &&
        storage.guestImportPrompt10Shown != true) {
      result = GuestImportPrompt.atTen;
    }

    '[GuestImportPrompt] 🔍 Evaluated prompt condition | uid=$uid | isAnonymous=${_session.isAnonymous} | count=$count | prompt10Shown=${storage.guestImportPrompt10Shown} | prompt20Dismissed=${storage.guestImportPrompt20Dismissed} -> result=$result'
        .Log('GuestImportPromptService');

    return result;
  }

  Future<void> markShown(GuestImportPrompt prompt) async {
    '[GuestImportPrompt] 📌 Marking prompt as shown: $prompt'.Log(
      'GuestImportPromptService',
    );
    if (prompt == GuestImportPrompt.atTen) {
      CcAppStorage.instance.guestImportPrompt10Shown = true;
    }
    await CcAppStorage.instance.save();
  }

  Future<void> dismissFinalWarning() async {
    '[GuestImportPrompt] 🚫 Final warning permanently dismissed by user'.Log(
      'GuestImportPromptService',
    );
    CcAppStorage.instance.guestImportPrompt20Dismissed = true;
    await CcAppStorage.instance.save();
  }

  Future<void> maybeShow(BuildContext context) async {
    if (_promptInFlight || !context.mounted) return;
    final prompt = await evaluate();
    if (prompt == null || !context.mounted) return;
    _promptInFlight = true;
    '[GuestImportPrompt] 🚀 Presenting guest import bottom sheet | prompt=$prompt'
        .Log('GuestImportPromptService');
    if (prompt == GuestImportPrompt.atTen) {
      await markShown(prompt);
    }
    if (!context.mounted) return;
    final import = await GuestImportPromptSheet.show(context, prompt: prompt);
    _promptInFlight = false;
    if (import != true && prompt == GuestImportPrompt.finalWarning) {
      await dismissFinalWarning();
    }
    if (import == true && context.mounted) {
      '[GuestImportPrompt] 🔗 User chose Import -> Navigating to Auth flow'.Log(
        'GuestImportPromptService',
      );
      getIt<AuthCoordinator>().navigateToLogin(context);
    }
  }

  void maybeShowFromCurrentContext() {
    final context = Get.context;
    if (context != null) {
      unawaited(maybeShow(context));
    }
  }

  Future<int> _count<T>(String boxName) async {
    try {
      final box = Hive.isBoxOpen(boxName)
          ? Hive.box<T>(boxName)
          : await Hive.openBox<T>(boxName);
      if (T == TransactionModel) {
        return box.values.where((value) {
          final transaction = value as TransactionModel;
          return transaction.deletedAt == null;
        }).length;
      }
      if (T == CategoryModel) {
        return box.values.where((value) {
          final category = value as CategoryModel;
          return !CategorySeed.categories.any((seed) => seed.id == category.id);
        }).length;
      }
      return box.length;
    } catch (_) {
      return 0;
    }
  }
}
