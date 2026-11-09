import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_x/smart_entry_preview_state.dart';
import 'smart_entry_preview_row_card.dart';
import 'smart_entry_sheet_header.dart';
import 'transaction_submit_button.dart';

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
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.padding.top + kToolbarHeight;

    return Obx(
      () => PopScope(
        canPop: !state.isCommitting.value,
        child: Padding(
          padding: EdgeInsets.only(
            top: topInset,
            bottom: mediaQuery.viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              Flexible(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
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
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.PAGE_XS)),
      itemCount: state.rows.length,
      separatorBuilder: (context, _) => Column(
        children: [
          const CcSpaceSM(),
          CcDividerHorizontalLine(
            color: context.ccColorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          const CcSpaceSM(),
        ],
      ),
      itemBuilder: (context, index) {
        final row = state.rows[index];
        final isEven = index.isEven;
        final scheme = context.ccColorScheme;

        return Container(
          decoration: BoxDecoration(
            color: isEven
                ? scheme.surfaceVariant.withValues(alpha: 0.9)
                : scheme.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: context.brLg,
          ),
          padding: EdgeInsets.all(
            context.respPadding(CcPaddingParams.SPACE_MD),
          ),
          child: SmartEntryPreviewRowCard(
            key: ValueKey(row.id),
            state: state,
            row: row,
          ),
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
              maxLines: 2,
              textStyle: context.ccTextTheme.labelMedium?.copyWith(
                color: scheme.error,
              ),
            ),
            const CcSpaceSM(),
          ],
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return TransactionSubmitButton(
      text: _confirmLabel(),
      isSubmitting: state.isCommitting.value,
      isEnabled: state.canConfirm,
      onTap: () => _confirm(context),
      activeColor: context.ccColorScheme.primary,
      widthFactor: 0.5,
      height: context.respDim(40),
      leadingIcon: Icons.check_circle_outline_rounded,
      leadingIconSize: 22,
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
