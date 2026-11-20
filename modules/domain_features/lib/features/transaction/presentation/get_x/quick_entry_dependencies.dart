import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/contracts/guideline_provider.dart';
import '../../../../core/contracts/user_level_provider.dart';
import '../../../../core/helper/ai_fallback_preference_datasource.dart';
import '../../../category/domain/usecases/get_categories_usecase.dart';
import '../../../firestore/guest_login_prompt_service.dart';
import '../../../notification/domain/usecases/check_budget_threshold_usecase.dart';
import '../../domain/usecases/create_transaction_batch_usecase.dart';
import '../../domain/usecases/parse_quick_entry_usecase.dart';
import '../../domain/usecases/parse_smart_entry_usecase.dart';

/// Everything [QuickEntryMixin] and [QuickEntryBatchMixin] need, injected as
/// one object: a mixin has no constructor, so each host controller takes this
/// through its own constructor and exposes it as `quickEntryDeps`.
@lazySingleton
class QuickEntryDependencies {
  QuickEntryDependencies(
    this.getCategories,
    this.parseQuickEntry,
    this.parseSmartEntry,
    this.createTransactionBatch,
    this.checkBudgetThreshold,
    this.aiPreferences,
    this.userLevel,
    this.guideline,
    this.guestLoginPrompt,
    this.speechRecognizer,
  );

  final GetCategoriesUseCase getCategories;
  final ParseQuickEntryUseCase parseQuickEntry;
  final ParseSmartEntryUseCase parseSmartEntry;
  final CreateTransactionBatchUseCase createTransactionBatch;
  final CheckBudgetThresholdUseCase checkBudgetThreshold;
  final AiFallbackPreferenceDataSource aiPreferences;
  final UserLevelProvider userLevel;
  final GuidelineProvider guideline;
  final GuestLoginPromptService guestLoginPrompt;
  final CcSpeechRecognizer speechRecognizer;
}
