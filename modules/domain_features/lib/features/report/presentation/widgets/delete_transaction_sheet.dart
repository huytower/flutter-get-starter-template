import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../get_x/report_controller.dart';

class DeleteTransactionSheet extends StatefulWidget {
  const DeleteTransactionSheet({
    super.key,
    required this.transaction,
  });

  final TransactionEntity transaction;

  static Future<Result<Unit, CcFailure>?> show(
    BuildContext context,
    TransactionEntity transaction,
  ) {
    return showModalBottomSheet<Result<Unit, CcFailure>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeleteTransactionSheet(transaction: transaction),
    );
  }

  @override
  State<DeleteTransactionSheet> createState() =>
      _DeleteTransactionSheetState();
}

class _DeleteTransactionSheetState extends State<DeleteTransactionSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context, scheme),
        _buildBody(context, scheme),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
        vertical: context.respPadding(CcPaddingParams.SPACE_LG),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.error, scheme.errorContainer],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.respDim(24)),
          topRight: Radius.circular(context.respDim(24)),
        ),
      ),
      child: Row(
        children: [
          CcIconToken(
            Icons.delete_outline_rounded,
            size: context.respIconSize(baseSize: 20),
            color: scheme.onError,
          ),
          const CcSpaceSM(),
          CcText(
            el.tr(CcLocaleKeys.transaction_delete_title),
            maxLines: 1,
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              color: scheme.onError,
              fontWeight: CcTypographyParams.semiBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme scheme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.respDim(24)),
          bottomRight: Radius.circular(context.respDim(24)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDescription(context, scheme),
          _buildActions(context, scheme),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context, ColorScheme scheme) {
    return CcSymmetricPadding(
      horizontal: CcPaddingParams.PAGE_MD,
      vertical: CcPaddingParams.SPACE_MD,
      child: CcText(
        el.tr(CcLocaleKeys.transaction_delete_confirm_desc),
        maxLines: 5,
        textStyle: context.ccTextTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          height: 1.4,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildActions(BuildContext context, ColorScheme scheme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.respPadding(CcPaddingParams.PAGE_MD),
        0,
        context.respPadding(CcPaddingParams.PAGE_MD),
        context.respPadding(CcPaddingParams.SPACE_XS),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: CcText(
              el.tr(CcLocaleKeys.common_cancel),
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                color: scheme.primary,
                fontWeight: CcTypographyParams.semiBold,
              ),
            ),
          ),
          const CcSpaceSM(),
          TextButton(
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() => _isLoading = true);
                    try {
                      final result = await _delete(context);
                      if (context.mounted) {
                        Navigator.of(context).pop(result);
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
            child: CcText(
              _isLoading
                  ? ''
                  : el.tr(CcLocaleKeys.common_delete),
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                color: scheme.error,
                fontWeight: CcTypographyParams.semiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Result<Unit, CcFailure>> _delete(BuildContext context) async {
    if (!mounted) return const Success(unit);
    final repo = getIt<TransactionRepository>();
    final result = await repo.deleteTransaction(widget.transaction.id);

    if (result.isSuccess() && context.mounted) {
      CcSnackBarHelper.showSuccessSnackBar(
        context: context,
        message: el.tr(CcLocaleKeys.common_delete),
      );
      if (Get.isRegistered<ReportController>()) {
        await Get.find<ReportController>().load(showLoading: false);
      }
    } else if (context.mounted) {
      CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: result.tryGetError()?.message ?? el.tr(CcLocaleKeys.app_error_general),
      );
    }

    return result.map(
      successMapper: (_) => unit,
      errorMapper: (e) => e,
    );
  }
}
