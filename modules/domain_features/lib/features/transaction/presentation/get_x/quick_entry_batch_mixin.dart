import 'dart:async';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../notification/domain/usecases/check_budget_threshold_usecase.dart';
import '../../domain/entities/parsed_transaction_entity.dart';
import '../../domain/entities/smart_entry_input.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/create_transaction_batch_usecase.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../domain/usecases/parse_smart_entry_usecase.dart';
import 'quick_entry_mixin.dart';
import 'smart_entry_preview_state.dart';

mixin QuickEntryBatchMixin on QuickEntryMixin {
  static const int quickEntryBatchLimit = 5;

  @override
  List<String> get quickEntryCloudCategoryTypes =>
      quickEntryCategoryType == CategoryType.income
      ? const [CategoryType.income, CategoryType.expense]
      : const [CategoryType.expense, CategoryType.income];

  @override
  int get quickEntryCloudMaxTransactions =>
      ParseSmartEntryUseCase.defaultMaxTransactions;

  @override
  bool get quickEntryCommitsDirectly => true;

  Future<void> submitQuickEntryFromGallery(BuildContext context) async {
    final (isCurrentGeneration, resetParsingIfCurrent) =
        trackQuickEntryGeneration();
    final languageCode = el.EasyLocalization.of(context)?.locale.languageCode;

    '[AI_PARSING] 📸 Gallery multi-picker started'.Log('QuickEntryBatchMixin');
    final pickResult = await CcReceiptScanHelper.pickReceiptImages(
      limit: quickEntryBatchLimit,
    );
    if (!isCurrentGeneration()) return;
    if (!context.mounted) {
      resetParsingIfCurrent();
      return;
    }
    final images = pickResult.images;
    if (images.isEmpty) {
      '[AI_PARSING] ❌ No images picked'.Log('QuickEntryBatchMixin');
      resetParsingIfCurrent();
      if (pickResult.permissionDenied) {
        quickEntryErrorKey.value =
            CcLocaleKeys.quick_entry_photo_permission_denied;
      } else if (pickResult.failed) {
        quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
      }
      return;
    }
    if (images.length == 1) {
      await resolvePickedReceipt(context, images.first);
      return;
    }

    '[AI_PARSING] ☁️ Escalating ${images.length} images to Gemini...'.Log(
      'QuickEntryBatchMixin',
    );
    final cloud = await runSmartEntry(
      input: SmartEntryImagesInput([
        for (final image in images)
          (bytes: image.bytes, mimeType: image.mimeType),
      ]),
      local: const ParsedTransactionEntity(),
      languageCode: languageCode,
    );
    resetParsingIfCurrent();
    if (!isCurrentGeneration()) return;

    if (cloud.errorKey != null) {
      quickEntryErrorKey.value = cloud.errorKey;
      return;
    }
    if (cloud.rows.isEmpty) {
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
      return;
    }
    if (context.mounted) await presentQuickEntryPreview(context, cloud.rows);
  }

  @override
  Future<SmartEntryCommitResult> commitQuickEntryRows(
    BuildContext context,
    List<ParsedTransactionEntity> rows,
  ) async {
    if (isSubmitting.value) return const SmartEntryCommitResult(saved: 0);

    final categories = {
      for (final category
          in (await getIt<GetCategoriesUseCase>().call()).tryGetSuccess() ??
              const <CategoryEntity>[])
        category.id: category,
    };
    final now = DateTime.now();
    final params = [for (final row in rows) _toParams(row, categories, now)];

    isSubmitting.value = true;
    final result = await getIt<CreateTransactionBatchUseCase>().call(params);
    isSubmitting.value = false;

    final savedParams = params.take(result.saved).toList();
    if (savedParams.isNotEmpty) {
      _checkBudgetThresholds(savedParams);
      await refreshParent();
      if (Get.isRegistered<GuidelineController>()) {
        unawaited(
          Get.find<GuidelineController>().completeTask('first_transaction'),
        );
      }
    }

    final failure = result.failure;
    if (failure == null) {
      if (context.mounted) _showSavedNotice(context, params.length);
      return SmartEntryCommitResult(saved: params.length);
    }
    return SmartEntryCommitResult(
      saved: result.saved,
      error: el.tr(
        result.saved == 0
            ? CcLocaleKeys.smart_entry_preview_save_failed
            : CcLocaleKeys.smart_entry_preview_save_partial,
        namedArgs: {
          'saved': '${result.saved}',
          'total': '${params.length}',
          'index': '${(result.failedAt ?? 0) + 1}',
          'reason': el.tr(failure.message),
        },
      ),
    );
  }

  void _checkBudgetThresholds(List<CreateTransactionParams> saved) {
    final spentByCategory = <String, int>{};
    for (final params in saved) {
      if (params.type != TransactionType.expense) continue;
      spentByCategory.update(
        params.categoryId,
        (sum) => sum + params.amount,
        ifAbsent: () => params.amount,
      );
    }
    spentByCategory.forEach((categoryId, amount) {
      unawaited(
        getIt<CheckBudgetThresholdUseCase>().call(
          categoryId: categoryId,
          transactionAmount: amount,
        ),
      );
    });
  }

  CreateTransactionParams _toParams(
    ParsedTransactionEntity row,
    Map<String, CategoryEntity> categories,
    DateTime now,
  ) {
    final category = categories[row.categoryId];
    final date = row.date;
    return CreateTransactionParams(
      type: (row.type ?? quickEntryCategoryType) == CategoryType.income
          ? TransactionType.income
          : TransactionType.expense,
      amount: row.amount ?? 0,
      categoryId: row.categoryId ?? '',
      categoryLabel: category != null ? el.tr(category.nameKey) : '',
      categoryIconCode: category?.iconCode,
      categoryIconFamily: category?.iconFamily,
      walletId: row.walletId ?? selectedWalletId.value ?? '',
      note: row.note,
      date: date == null
          ? now
          : DateTime(date.year, date.month, date.day, now.hour, now.minute),
    );
  }

  void _showSavedNotice(BuildContext context, int count) {
    CcSnackBarHelper.showSuccessSnackBar(
      context: context,
      message: count > 1
          ? el.tr(
              CcLocaleKeys.smart_entry_preview_saved_many,
              namedArgs: {'count': '$count'},
            )
          : el.tr(CcLocaleKeys.smart_entry_preview_saved_one),
    );
  }
}
