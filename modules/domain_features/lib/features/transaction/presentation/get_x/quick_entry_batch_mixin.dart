import 'dart:async';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/money_format_helper.dart';
import '../../domain/entities/parsed_transaction_entity.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../notification/domain/usecases/check_budget_threshold_usecase.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/create_transaction_batch_usecase.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../domain/usecases/parse_quick_entry_usecase.dart';
import 'quick_entry_mixin.dart';

mixin QuickEntryBatchMixin on QuickEntryMixin {
  static const int quickEntryBatchLimit = 5;

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

    if (!await passQuickEntryCloudGate(
      context: context,
      isCurrentGeneration: isCurrentGeneration,
      resetParsingIfCurrent: resetParsingIfCurrent,
    )) {
      '[AI_PARSING] ⛔ Cloud gate blocked batch escalation'.Log(
        'QuickEntryBatchMixin',
      );
      return;
    }

    '[AI_PARSING] ☁️ Escalating ${images.length} images to Gemini...'.Log(
      'QuickEntryBatchMixin',
    );
    final results = await getIt<ParseQuickEntryUseCase>().parseImagesWithCloud(
      images: [
        for (final image in images)
          (bytes: image.bytes, mimeType: image.mimeType),
      ],
      categoryType: quickEntryCategoryType,
      groupIds: quickEntryCategoryGroupIds,
      languageCode: languageCode,
    );
    if (results != null && quickEntryAvailableCategoryIds.isEmpty) {
      await refreshQuickEntryCategories();
    }
    resetParsingIfCurrent();
    if (!isCurrentGeneration()) return;

    if (results == null) {
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
      return;
    }

    final failedImages = [
      for (var i = 0; i < results.length; i++)
        if (!_isBatchItemUsable(results[i])) i + 1,
    ];
    if (failedImages.isNotEmpty) {
      '[AI_PARSING] ⛔ Batch rejected | failedImages=$failedImages'.Log(
        'QuickEntryBatchMixin',
      );
      if (context.mounted) {
        CcSnackBarHelper.showErrorSnackBar(
          context: context,
          message: el.tr(
            CcLocaleKeys.quick_entry_batch_failed,
            namedArgs: {'indexes': failedImages.join(', ')},
          ),
        );
      }
      return;
    }

    quickEntrySuggestion.value = null;
    quickEntryBatch.assignAll(results.whereType<ParsedTransactionEntity>());
    '[AI_PARSING] ✨ Batch ready | count=${quickEntryBatch.length}'.Log(
      'QuickEntryBatchMixin',
    );
    startAutoSaveCountdown(() => saveQuickEntryBatch(context));
  }

  bool _isBatchItemUsable(ParsedTransactionEntity? result) {
    if (result == null) return false;
    final amount = result.amount;
    return amount != null && amount > 0 && !isCategoryMissingFor(result);
  }

  Future<void> saveQuickEntryBatch(BuildContext context) async {
    if (isSubmitting.value || quickEntryBatch.isEmpty) return;
    cancelAutoSaveCountdown();

    final isExpense = quickEntryCategoryType != CategoryType.income;
    final now = DateTime.now();
    final params = [
      for (final item in quickEntryBatch)
        _toParams(item, isExpense: isExpense, now: now),
    ];
    quickEntryBatch.clear();
    isSubmitting.value = true;

    final result = await getIt<CreateTransactionBatchUseCase>().call(params);
    isSubmitting.value = false;

    final savedParams = params.take(result.saved).toList();
    if (savedParams.isNotEmpty) {
      if (isExpense) _checkBudgetThresholds(savedParams);
      await refreshParent();
      if (Get.isRegistered<GuidelineController>()) {
        unawaited(
          Get.find<GuidelineController>().completeTask('first_transaction'),
        );
      }
    }

    if (!context.mounted) return;
    _showBatchSaveNotice(context, result, params.length, savedParams);
  }

  void _checkBudgetThresholds(List<CreateTransactionParams> saved) {
    final spentByCategory = <String, int>{};
    for (final params in saved) {
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

  String _resolveWalletId(String? suggested) {
    final isSelectable =
        suggested != null && wallets.any((w) => w.id == suggested);
    return isSelectable ? suggested : selectedWalletId.value ?? '';
  }

  CreateTransactionParams _toParams(
    ParsedTransactionEntity item, {
    required bool isExpense,
    required DateTime now,
  }) {
    final category = findQuickEntryCategory(item.categoryId!);
    final date = item.date;
    return CreateTransactionParams(
      type: isExpense ? TransactionType.expense : TransactionType.income,
      amount: item.amount!,
      categoryId: item.categoryId!,
      categoryLabel: category != null ? el.tr(category.nameKey) : '',
      categoryIconCode: category?.iconCode,
      categoryIconFamily: category?.iconFamily,
      walletId: _resolveWalletId(item.walletId),
      note: item.note,
      date: date == null
          ? now
          : DateTime(date.year, date.month, date.day, now.hour, now.minute),
    );
  }

  void _showBatchSaveNotice(
    BuildContext context,
    BatchSaveResult result,
    int total,
    List<CreateTransactionParams> savedParams,
  ) {
    final failure = result.failure;
    if (failure == null) {
      CcSnackBarHelper.showSuccessSnackBar(
        context: context,
        message: el.tr(
          CcLocaleKeys.quick_entry_batch_saved,
          namedArgs: {
            'count': '${savedParams.length}',
            'total': MoneyFormatter.formatWithSymbol(
              savedParams.fold<int>(0, (sum, p) => sum + p.amount),
              currencyCode: currencyCode.value,
            ),
          },
        ),
      );
      return;
    }

    CcSnackBarHelper.showErrorSnackBar(
      context: context,
      message: el.tr(
        result.saved == 0
            ? CcLocaleKeys.quick_entry_batch_save_failed
            : CcLocaleKeys.quick_entry_batch_partial,
        namedArgs: {
          'saved': '${result.saved}',
          'total': '$total',
          'index': '${(result.failedAt ?? 0) + 1}',
          'reason': el.tr(failure.message),
        },
      ),
    );
  }
}
