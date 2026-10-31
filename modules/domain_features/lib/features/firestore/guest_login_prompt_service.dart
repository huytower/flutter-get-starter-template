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
import '../profile/presentation/widgets/guest_login_prompt_sheet.dart';
import '../reconciliation/data/models/reconciliation_model.dart';
import '../transaction/data/models/transaction_model.dart';
import '../wallet/data/models/wallet_hive_model.dart';

enum GuestLoginPrompt { atEight, finalWarning }

@lazySingleton
class GuestLoginPromptService {
  static const int _firstPromptThreshold = 8;
  static const int _finalPromptThreshold = 15;

  final SessionContract _session;
  bool _promptInFlight = false;

  GuestLoginPromptService(this._session);

  Future<int> countFinancialRecords() async {
    final counts = await Future.wait([
      _count<WalletHiveModel>(CcHiveBox.WALLET_BOX_NAME),
      _count<TransactionModel>(CcHiveBox.TRANSACTION_BOX_NAME),
      _count<BudgetLimitModel>(CcHiveBox.BUDGET_BOX_NAME),
      _count<LiabilityModel>(CcHiveBox.LIABILITY_BOX_NAME),
      _count<CategoryModel>(CcHiveBox.CATEGORY_BOX_NAME),
      _count<ReconciliationModel>(CcHiveBox.RECONCILIATION_BOX_NAME),
    ]);
    return counts.fold<int>(0, (int total, int count) => total + count);
  }

  Future<GuestLoginPrompt?> evaluate() async {
    if (_promptInFlight) return null;
    final isAuth = _session.isAuthenticated;
    final isAnon = _session.isAnonymous;
    if (isAuth && !isAnon) {
      return null;
    }

    final uid = _session.currentUser?.id ?? 'guest_local_user';

    final storage = CcAppStorage.instance;
    if (storage.guestLoginPromptSessionUid != uid) {
      storage.guestLoginPromptSessionUid = uid;
      storage.guestLoginPromptAtTimes7Shown = false;
      storage.guestLoginPrompt15Dismissed = false;
      await storage.save();
    }

    if (storage.guestLoginPrompt15Dismissed == true) {
      return null;
    }

    final count = await countFinancialRecords();
    if (count >= _finalPromptThreshold) {
      return GuestLoginPrompt.finalWarning;
    }

    return null;
  }

  Future<void> markShown(GuestLoginPrompt prompt) async {
    if (prompt == GuestLoginPrompt.atEight) {
      CcAppStorage.instance.guestLoginPromptAtTimes7Shown = true;
    }
    await CcAppStorage.instance.save();
  }

  Future<void> dismissFinalWarning() async {
    CcAppStorage.instance.guestLoginPrompt15Dismissed = true;
    await CcAppStorage.instance.save();
  }

  /// Resets prompt flags when user logs out from a logged-in user status to guest status.
  Future<void> resetPromptFlags() async {
    final storage = CcAppStorage.instance;
    storage.guestLoginPromptAtTimes7Shown = false;
    storage.guestLoginPrompt15Dismissed = false;
    storage.guestLoginPromptSessionUid = null;
    await storage.save();
  }

  Future<void> maybeShow(BuildContext context) async {
    if (_promptInFlight) return;
    final targetContext = context.mounted ? context : Get.context;
    if (targetContext == null) return;

    final prompt = await evaluate();
    if (prompt == null) return;

    final activeContext = targetContext.mounted ? targetContext : Get.context;
    if (activeContext == null) return;

    _promptInFlight = true;

    final choseLogin = await GuestLoginPromptSheet.show(
      activeContext,
      prompt: prompt,
    );
    _promptInFlight = false;

    if (choseLogin != true && prompt == GuestLoginPrompt.finalWarning) {
      await dismissFinalWarning();
    }
    if (choseLogin == true) {
      final navContext = Get.context ?? activeContext;
      getIt<AuthCoordinator>().navigateToLogin(navContext);
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
