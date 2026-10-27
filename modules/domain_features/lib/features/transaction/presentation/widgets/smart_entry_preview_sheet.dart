import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/money_format_helper.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../get_x/smart_entry_preview_state.dart';
import 'smart_entry_preview_row_card.dart';
import 'smart_entry_sheet_header.dart';

class SmartEntryPreviewSheet extends StatelessWidget {
  const SmartEntryPreviewSheet({
    super.key,
    required this.state,
    required this.onConfirm,
  });

  final SmartEntryPreviewState state;
  final SmartEntryCommit onConfirm;

  static Future<bool?> show(
    BuildContext context, {
    required SmartEntryPreviewState state,
    required SmartEntryCommit onConfirm,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          SmartEntryPreviewSheet(state: state, onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Obx(
      () => PopScope(
        canPop: !state.isCommitting.value,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),
                  Flexible(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(context.respDim(16)),
                          bottomRight: Radius.circular(context.respDim(16)),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(child: _buildRows(context)),
                          _buildFooter(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final count = state.rows.length;

    return SmartEntrySheetHeader(
      title: count > 1
          ? el.tr(
              CcLocaleKeys.smart_entry_preview_title_many,
              namedArgs: {'count': '$count'},
            )
          : el.tr(CcLocaleKeys.smart_entry_preview_title_one),
      subtitle: el.tr(CcLocaleKeys.smart_entry_preview_subtitle),
      trailing: CcCancelBtn.bouncing(
        onTap: () {
          if (!state.isCommitting.value) Navigator.of(context).pop(false);
        },
        iconColor: context.ccColorScheme.onPrimary,
      ),
    );
  }

  Widget _buildRows(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.PAGE_MD)),
      itemCount: state.rows.length,
      separatorBuilder: (_, _) => const CcSpaceMD(),
      itemBuilder: (context, index) {
        final row = state.rows[index];
        return SmartEntryPreviewRowCard(
          key: ValueKey(row.id),
          state: state,
          row: row,
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    final scheme = context.ccColorScheme;
    final error = state.errorText.value;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.respPadding(CcPaddingParams.PAGE_MD),
        0,
        context.respPadding(CcPaddingParams.PAGE_MD),
        context.respPadding(CcPaddingParams.SPACE_MD),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (error != null) ...[
            CcText(
              error,
              textStyle: context.ccTextTheme.labelMedium?.copyWith(
                color: scheme.error,
              ),
            ),
            const CcSpaceSM(),
          ],
          _buildSummary(context),
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final config = state.config;
    final parts = <String>[];
    if (config.showType) {
      for (final type in config.types) {
        final total = state.totalFor(type);
        if (total == 0) continue;
        final label = el.tr(
          type == CategoryType.income
              ? CcLocaleKeys.common_income
              : CcLocaleKeys.common_expense,
        );
        parts.add(
          '$label ${MoneyFormatter.formatWithSymbol(total, currencyCode: config.currencyCode)}',
        );
      }
    } else if (state.rows.length > 1) {
      final total = state.totalFor(config.types.first);
      parts.add(
        MoneyFormatter.formatWithSymbol(
          total,
          currencyCode: config.currencyCode,
        ),
      );
    }
    if (parts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: context.respDim(8)),
      child: CcText(
        parts.join(' · '),
        textStyle: context.ccTextTheme.labelLarge?.copyWith(
          color: context.ccColorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final scheme = context.ccColorScheme;
    final height = context.respDim(48);

    if (state.isCommitting.value) {
      return SizedBox(
        height: height,
        child: Center(
          child: SizedBox(
            width: context.respDim(24),
            height: context.respDim(24),
            child: CircularProgressIndicator(
              strokeWidth: context.respDim(2.5),
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
        ),
      );
    }

    return CcBaseBtn(
      title: _confirmLabel(),
      isEnable: state.canConfirm,
      bgColor: state.canConfirm ? [scheme.primary, scheme.primary] : null,
      onTap: () => _confirm(context),
    );
  }

  String _confirmLabel() {
    if (state.config.appliesToForm) {
      return el.tr(CcLocaleKeys.smart_entry_preview_apply_form);
    }
    final count = state.rows.length;
    return count > 1
        ? el.tr(
            CcLocaleKeys.smart_entry_preview_confirm_many,
            namedArgs: {'count': '$count'},
          )
        : el.tr(CcLocaleKeys.smart_entry_preview_confirm_one);
  }

  Future<void> _confirm(BuildContext context) async {
    if (!state.canConfirm) return;
    state.isCommitting.value = true;
    state.errorText.value = null;

    final result = await onConfirm(state.toEntities());

    state.isCommitting.value = false;
    state.dropSaved(result.saved);
    if (result.error == null || state.rows.isEmpty) {
      if (context.mounted) Navigator.of(context).pop(true);
      return;
    }
    state.errorText.value = result.error;
  }
}
