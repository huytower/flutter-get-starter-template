import 'dart:async';

import 'package:app_config/data/datasources/local/box/app_storage/prj_app_storage.dart';
import 'package:app_config/data/datasources/local/box/prj_hive_box.dart';
import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../budget_limit/data/models/budget_limit_model.dart';
import '../category/data/datasources/local/category_seed.dart';
import '../category/data/models/category_model.dart';
import '../liability/data/models/liability_model.dart';
import '../profile/presentation/widgets/guest_login_prompt_sheet.dart';
import '../reconciliation/data/models/reconciliation_model.dart';
import '../transaction/data/models/transaction_model.dart';
import '../wallet/data/models/wallet_hive_model.dart';

enum GuestLoginPrompt { firstReminder, finalWarning }

@lazySingleton
class GuestLoginPromptService {
  static const int _firstPromptThreshold = 8;
  static const int _finalPromptThreshold = 15;

  final SessionContract _session;
  bool _promptInFlight = false;

  GuestLoginPromptService(this._session, this._auth);

  final AuthCoordinator _auth;

  Future<int> countFinancialRecords() async {
    final counts = await Future.wait([
      _count<WalletHiveModel>(PrjHiveBox.WALLET_BOX_NAME),
      _count<TransactionModel>(PrjHiveBox.TRANSACTION_BOX_NAME),
      _count<BudgetLimitModel>(PrjHiveBox.BUDGET_BOX_NAME),
      _count<LiabilityModel>(PrjHiveBox.LIABILITY_BOX_NAME),
      _count<CategoryModel>(PrjHiveBox.CATEGORY_BOX_NAME),
      _count<ReconciliationModel>(PrjHiveBox.RECONCILIATION_BOX_NAME),
    ]);
    return counts.fold<int>(0, (int total, int count) => total + count);
  }

  Future<GuestLoginPrompt?> evaluate() async {
    final hasSignedIn = _session.isAuthenticated;
    final hasAnonymousSession = _session.isAnonymous;
    if (hasSignedIn && !hasAnonymousSession) {
      return null;
    }

    final uid = _session.currentUser?.id ?? 'guest_local_user';

    final storage = PrjAppStorage.instance;
    if (storage.guestLoginPromptSessionUid != uid) {
      storage.guestLoginPromptSessionUid = uid;
      storage.hasShownGuestLoginFirstReminder = false;
      storage.hasDismissedGuestLoginFinalWarning = false;
      await storage.save();
    }

    if (storage.hasDismissedGuestLoginFinalWarning == true) {
      return null;
    }

    final count = await countFinancialRecords();
    if (count >= _finalPromptThreshold) {
      return GuestLoginPrompt.finalWarning;
    }

    if (count >= _firstPromptThreshold &&
        storage.hasShownGuestLoginFirstReminder != true) {
      return GuestLoginPrompt.firstReminder;
    }

    return null;
  }

  Future<void> markShown(GuestLoginPrompt prompt) async {
    if (prompt == GuestLoginPrompt.firstReminder) {
      PrjAppStorage.instance.hasShownGuestLoginFirstReminder = true;
    }
    await PrjAppStorage.instance.save();
  }

  Future<void> dismissFinalWarning() async {
    PrjAppStorage.instance.hasShownGuestLoginFirstReminder = true;
    PrjAppStorage.instance.hasDismissedGuestLoginFinalWarning = true;
    await PrjAppStorage.instance.save();
  }

  /// Resets prompt flags when user logs out from a logged-in user status to guest status.
  Future<void> resetPromptFlags() async {
    final storage = PrjAppStorage.instance;
    storage.hasShownGuestLoginFirstReminder = false;
    storage.hasDismissedGuestLoginFinalWarning = false;
    storage.guestLoginPromptSessionUid = null;
    await storage.save();
  }

  Future<void> maybeShow(BuildContext context) async {
    if (_promptInFlight) return;
    _promptInFlight = true;

    try {
      final targetContext = context.mounted ? context : Get.context;
      if (targetContext == null) return;

      final prompt = await evaluate();
      if (prompt == null) return;

      final activeContext = targetContext.mounted ? targetContext : Get.context;
      if (activeContext == null || !activeContext.mounted) return;

      final choseLogin = await GuestLoginPromptSheet.show(
        activeContext,
        prompt: prompt,
      );

      if (prompt == GuestLoginPrompt.firstReminder) {
        await markShown(prompt);
      } else if (prompt == GuestLoginPrompt.finalWarning) {
        await dismissFinalWarning();
      }

      if (choseLogin == true) {
        final navContext = (activeContext.mounted
            ? activeContext
            : Get.context);
        if (navContext != null && navContext.mounted) {
          // ignore: use_build_context_synchronously
          _auth.navigateToLogin(navContext);
        }
      }
    } finally {
      _promptInFlight = false;
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
