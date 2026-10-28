import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../get_x/smart_entry_preview_state.dart';
import 'smart_entry_amount_field.dart';
import 'smart_entry_option_picker_sheet.dart';
import 'smart_entry_preview_fields.dart';

class SmartEntryPreviewRowCard extends StatelessWidget {
  const SmartEntryPreviewRowCard({
    super.key,
    required this.state,
    required this.row,
  });

  final SmartEntryPreviewState state;
  final SmartEntryPreviewRow row;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final isValid = state.isValid(row);
    final config = state.config;

    return Container(
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: context.brLg,
        border: Border.all(
          color: isValid
              ? scheme.outlineVariant.withValues(alpha: 0.4)
              : scheme.error.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config.showType || state.rows.length > 1) _buildHeader(context),
          SmartEntryAmountField(
            amount: row.amount,
            currencyCode: config.currencyCode,
            hasError: row.amount <= 0,
            onChanged: (value) =>
                state.edit(row.id, (r) => r.copyWith(amount: value)),
          ),
          const CcSpaceSM(),
          Wrap(
            spacing: context.respDim(8),
            runSpacing: context.respDim(8),
            children: [
              if (config.showCategory) _buildCategoryChip(context),
              _buildWalletChip(context),
              _buildDateChip(context),
            ],
          ),
          const CcSpaceSM(),
          SmartEntryNoteField(
            note: row.note,
            onChanged: (value) =>
                state.edit(row.id, (r) => r.copyWith(note: value)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.respDim(4)),
      child: Row(
        children: [
          if (state.config.showType)
            SmartEntryTypeToggle(
              types: state.config.types,
              selected: row.type,
              onChanged: (type) => state.setType(row.id, type),
            ),
          const Spacer(),
          if (state.rows.length > 1)
            CcCancelBtn.bouncing(
              onTap: () => state.remove(row.id),
              iconColor: context.ccColorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context) {
    final category = state.categoryById(row.categoryId);
    final title = el.tr(CcLocaleKeys.smart_entry_preview_pick_category);

    return SmartEntryFieldChip(
      icon: category == null
          ? Icons.category_outlined
          : iconDataFromCode(
              category.iconCode,
              fontFamily: category.iconFamily,
            ),
      label: category == null ? title : el.tr(category.nameKey),
      hasError: category == null,
      onTap: () async {
        final picked = await SmartEntryOptionPickerSheet.show(
          context,
          title: title,
          selectedId: row.categoryId,
          options: [
            for (final item in state.categoriesFor(row.type))
              (
                id: item.id,
                label: el.tr(item.nameKey),
                icon: iconDataFromCode(
                  item.iconCode,
                  fontFamily: item.iconFamily,
                ),
              ),
          ],
        );
        if (picked == null) return;
        state.edit(row.id, (r) => r.copyWith(categoryId: picked));
      },
    );
  }

  Widget _buildWalletChip(BuildContext context) {
    final wallet = state.walletById(row.walletId);
    final title = el.tr(CcLocaleKeys.smart_entry_preview_pick_wallet);

    return SmartEntryFieldChip(
      icon: wallet == null
          ? Icons.account_balance_wallet_outlined
          : iconDataFromCode(wallet.iconCode),
      label: wallet?.name ?? title,
      hasError: wallet == null,
      onTap: () async {
        final picked = await SmartEntryOptionPickerSheet.show(
          context,
          title: title,
          selectedId: row.walletId,
          options: [
            for (final item in state.wallets)
              (
                id: item.id,
                label: item.name,
                icon: iconDataFromCode(item.iconCode),
              ),
          ],
        );
        if (picked == null) return;
        state.edit(row.id, (r) => r.copyWith(walletId: picked));
      },
    );
  }

  Widget _buildDateChip(BuildContext context) {
    return SmartEntryFieldChip(
      icon: Icons.calendar_today_outlined,
      label: el.DateFormat('dd/MM/yyyy').format(row.date),
      onTap: () async {
        final picked = await TransactionFormHelpers.pickDate(context, row.date);
        if (picked == null) return;
        state.edit(
          row.id,
          (r) => r.copyWith(
            date: TransactionFormHelpers.updateDatePreserveTime(r.date, picked),
          ),
        );
      },
    );
  }
}
