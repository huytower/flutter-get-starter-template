import 'dart:async';

import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../domain/entities/parsed_transaction_entity.dart';
import '../../domain/entities/smart_entry_input.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../domain/usecases/parse_smart_entry_usecase.dart';
import '../helper/receipt_image_picker_helper.dart';
import 'quick_entry_session.dart';
import 'smart_entry_preview_state.dart';

class QuickEntryBatchSession extends QuickEntrySession {
  QuickEntryBatchSession(super.host, super.handler);

  static const int quickEntryBatchLimit = 5;

  @override
  List<String> get quickEntryCloudCategoryTypes =>
      host.quickEntryCategoryType == CategoryType.income
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

    '[AI_PARSING] 📸 Gallery multi-picker started'.Log(
      'QuickEntryBatchSession',
    );
    final pickResult = await ReceiptImagePickerHelper.pickReceiptImages(
      limit: quickEntryBatchLimit,
    );
    if (!isCurrentGeneration()) return;
    if (!context.mounted) {
      resetParsingIfCurrent();
      return;
    }
    final images = pickResult.images;
    if (images.isEmpty) {
      '[AI_PARSING] ❌ No images picked'.Log('QuickEntryBatchSession');
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

    '[AI_PARSING] [GEMINI] ☁️ Escalating ${images.length} images to Gemini AI...'
        .Log('QuickEntryBatchSession');
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
      '[AI_PARSING] [GEMINI] ❌ Gemini AI batch parsing failed | errorKey=${cloud.errorKey}'
          .Log('QuickEntryBatchSession');
      quickEntryErrorKey.value = cloud.errorKey;
      return;
    }
    if (cloud.rows.isEmpty) {
      '[AI_PARSING] [GEMINI] ⚠️ Gemini AI batch parsing returned 0 rows'.Log(
        'QuickEntryBatchSession',
      );
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
      return;
    }
    '[AI_PARSING] [GEMINI] ✅ Gemini AI batch parsing succeeded | rowsCount=${cloud.rows.length} rows=${cloud.rows.map((r) => r.toJson()).toList()}'
        .Log('QuickEntryBatchSession');
    if (context.mounted) await presentQuickEntryPreview(context, cloud.rows);
  }

  @override
  Future<SmartEntryCommitResult> commitQuickEntryRows(
    BuildContext context,
    List<ParsedTransactionEntity> rows,
  ) async {
    if (host.isSubmitting.value) return const SmartEntryCommitResult(saved: 0);

    final categories = {
      for (final category
          in (await handler.parser.loadCategories()).tryGetSuccess() ??
              const <CategoryEntity>[])
        category.id: category,
    };
    final now = DateTime.now();
    final params = [for (final row in rows) _toParams(row, categories, now)];

    host.isSubmitting.value = true;
    final result = await handler.committer.save(params);
    host.isSubmitting.value = false;

    final savedParams = params.take(result.saved).toList();
    if (savedParams.isNotEmpty) {
      _checkBudgetThresholds(savedParams);
      await host.refreshParent();
      handler.committer.afterSaved(context);
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
      handler.committer.checkBudgetThreshold(
        categoryId: categoryId,
        transactionAmount: amount,
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
      type: (row.type ?? host.quickEntryCategoryType) == CategoryType.income
          ? TransactionType.income
          : TransactionType.expense,
      amount: row.amount ?? 0,
      categoryId: row.categoryId ?? '',
      categoryLabel: category != null ? el.tr(category.nameKey) : '',
      categoryIconCode: category?.iconCode,
      categoryIconFamily: category?.iconFamily,
      walletId: row.walletId ?? host.selectedWalletId.value ?? '',
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
