import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/contracts/user_level_provider.dart';
import '../../../../core/domain/entities/category_entity.dart';
import '../../../../core/helper/ai_fallback_preference_datasource.dart';
import '../../../category/domain/usecases/get_categories_usecase.dart';
import '../../domain/entities/parsed_transaction_entity.dart';
import '../../domain/entities/smart_entry_input.dart';
import '../../domain/usecases/parse_quick_entry_usecase.dart';
import '../../domain/usecases/parse_smart_entry_usecase.dart';

/// Turns quick-entry text, voice transcripts or receipt images into parsed
/// transactions: the on-device parser first, the cloud AI when the user's
/// level, consent and daily quota allow it.
@injectable
class QuickEntryParser {
  QuickEntryParser(
    this._getCategories,
    this._parseQuickEntry,
    this._parseSmartEntry,
    this.aiPreferences,
    this._userLevel,
  );

  final GetCategoriesUseCase _getCategories;
  final ParseQuickEntryUseCase _parseQuickEntry;
  final ParseSmartEntryUseCase _parseSmartEntry;
  final UserLevelProvider _userLevel;

  /// Consent and daily quota for the cloud AI; also shown to the consent sheet.
  final AiFallbackPreferenceDataSource aiPreferences;

  /// Quick entry with AI is a level-gated feature.
  bool get canUseAiSmartEntry => _userLevel.status.canUseAiSmartEntry;

  Future<Result<List<CategoryEntity>, CcFailure>> loadCategories() =>
      _getCategories.call();

  Future<ParsedTransactionEntity> parseLocally(
    String text, {
    required String categoryType,
    List<String>? groupIds,
  }) => _parseQuickEntry.parseLocally(
    text,
    categoryType: categoryType,
    groupIds: groupIds,
  );

  Future<Result<List<ParsedTransactionEntity>, CcFailure>> parseSmart({
    required SmartEntryInput input,
    required List<String> categoryTypes,
    List<String>? groupIds,
    String? languageCode,
    required int maxTransactions,
    ParsedTransactionEntity? localResult,
  }) => _parseSmartEntry.call(
    input: input,
    categoryTypes: categoryTypes,
    groupIds: groupIds,
    languageCode: languageCode,
    maxTransactions: maxTransactions,
    localResult: localResult,
  );
}
