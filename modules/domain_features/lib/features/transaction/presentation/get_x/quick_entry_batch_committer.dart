import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/contracts/guideline_provider.dart';
import '../../../firestore/guest_login_prompt_service.dart';
import '../../../notification/domain/usecases/check_budget_threshold_usecase.dart';
import '../../domain/usecases/create_transaction_batch_usecase.dart';
import '../../domain/usecases/create_transaction_usecase.dart';

/// Saves several quick-entry transactions at once and runs what follows a
/// successful save (budget alerts, guideline step, guest sign-in prompt).
@injectable
class QuickEntryBatchCommitter {
  QuickEntryBatchCommitter(
    this._createBatch,
    this._checkBudgetThreshold,
    this._guideline,
    this._guestLoginPrompt,
  );

  final CreateTransactionBatchUseCase _createBatch;
  final CheckBudgetThresholdUseCase _checkBudgetThreshold;
  final GuidelineProvider _guideline;
  final GuestLoginPromptService _guestLoginPrompt;

  Future<BatchSaveResult> save(List<CreateTransactionParams> batch) =>
      _createBatch.call(batch);

  void checkBudgetThreshold({
    required String categoryId,
    required int transactionAmount,
  }) => unawaited(
    _checkBudgetThreshold.call(
      categoryId: categoryId,
      transactionAmount: transactionAmount,
    ),
  );

  /// After the first successful save: guideline step + guest sign-in prompt.
  void afterSaved(BuildContext context) {
    unawaited(_guideline.completeTask('first_transaction'));
    if (context.mounted) unawaited(_guestLoginPrompt.maybeShow(context));
  }
}
