import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/domain/entities/category_entity.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';
import 'package:theme/export_theme.dart';

import '../../../wallet/presentation/widgets/wallet_strip_card.dart';
import '../get_x/smart_entry_preview_state.dart';
import 'smart_entry_amount_field.dart';
import 'smart_entry_category_strip.dart';
import 'smart_entry_preview_fields.dart';

class SmartEntryPreviewRowCard extends StatelessWidget {
  const SmartEntryPreviewRowCard({
    super.key,
    required this.state,
    required this.row,
    this.index,
  });

  final SmartEntryPreviewState state;
  final SmartEntryPreviewRow row;
  final int? index;

  @override
  Widget build(BuildContext context) {
    final config = state.config;
    final hasIncome = row.type == CategoryType.income;
    final activeColor = hasIncome ? context.incomeAccent : context.expenseAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (config.showType || state.rows.length > 1) _buildHeader(context),
        const CcSpaceSM(),
        SmartEntryAmountField(
          amount: row.amount,
          currencyCode: config.currencyCode,
          hasError: row.amount <= 0,
        ),
        if (config.showCategory) ...[
          const CcSpaceSM(),
          _buildCategorySelectionSection(context, activeColor),
        ],
        const CcSpaceSM(),
        _buildWalletSelectionSection(context, activeColor),
        const CcSpaceSM(),
        _buildDateSelectionSection(context, activeColor),
        const CcSpaceSM(),
        SmartEntryNoteField(
          note: row.note,
          onChanged: (value) =>
              state.edit(row.id, (r) => r.copyWith(note: value)),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final rowNumber = (index ?? state.rows.indexOf(row)) + 1;
    final showBadge = state.rows.length > 1;

    return Padding(
      padding: EdgeInsets.only(bottom: context.respDim(4)),
      child: Row(
        children: [
          if (showBadge) ...[
            CcBadgeCounter(
              count: rowNumber,
              backgroundColor: context.ccColorScheme.error,
            ),
            const CcSpaceSM(),
          ],
          if (state.config.showType)
            Expanded(
              child: SmartEntryTypeToggle(
                types: state.config.types,
                selected: row.type,
                onChanged: (type) => state.setType(row.id, type),
              ),
            ),
          if (state.rows.length > 1)
            CcCancelButton.bouncing(
              onTap: () => state.remove(row.id),
              iconColor: context.ccColorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySelectionSection(
    BuildContext context,
    Color activeColor,
  ) {
    final categories = state.categoriesFor(row.type);
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(text: el.tr(PrjLocaleKeys.transaction_category)),
        const CcSpaceXS(),
        SmartEntryCategoryStrip(
          categories: categories,
          selectedCategoryId: row.categoryId,
          activeColor: activeColor,
          itemKeyPrefix: 'smart_preview_cat_${row.id}_',
          onSelected: (category) => state.edit(
            row.id,
            (r) => r.copyWith(categoryId: category.id),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletSelectionSection(BuildContext context, Color activeColor) {
    if (state.wallets.isEmpty) return const SizedBox.shrink();

    final labelKey = row.type == CategoryType.income
        ? PrjLocaleKeys.transaction_source_income
        : PrjLocaleKeys.transaction_source_expense;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(text: el.tr(labelKey)),
        const CcSpaceXS(),
        WalletStripCard(
          wallets: state.wallets,
          selectedWalletId: row.walletId,
          activeColor: activeColor,
          defaultBackgroundColor: context.verticalGradient(activeColor),
          onWalletSelected: (id) =>
              state.edit(row.id, (r) => r.copyWith(walletId: id)),
        ),
      ],
    );
  }

  Widget _buildDateSelectionSection(BuildContext context, Color activeColor) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final hasCustomDate =
        !_hasSameDay(row.date, now) && !_hasSameDay(row.date, yesterday);

    return Row(
      children: [
        CcFormLabel(text: el.tr(PrjLocaleKeys.transaction_time)),
        const CcSpaceSM(),
        if (hasCustomDate) ...[
          _buildDatePill(
            context,
            el.DateFormat('dd/MM/yyyy').format(row.date),
            row.date,
            activeColor,
            hasSelected: false,
          ),
        ],
      ],
    );
  }

  Widget _buildDatePill(
    BuildContext context,
    String label,
    DateTime date,
    Color activeColor, {
    required bool hasSelected,
  }) {
    final scheme = context.ccColorScheme;

    return CcText(
      label,
      textStyle: context.ccTextTheme.labelMedium?.copyWith(
        color: hasSelected ? activeColor : scheme.onSurfaceVariant,
        fontWeight: hasSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  bool _hasSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
