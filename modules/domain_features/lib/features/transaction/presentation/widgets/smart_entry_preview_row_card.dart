import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/data/data_source/color/prj_color.dart';

import '../../../category/domain/entities/category_entity.dart';
import '../../../wallet/presentation/widgets/wallet_strip_card.dart';
import '../get_x/smart_entry_preview_state.dart';
import 'smart_entry_amount_field.dart';
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
    final scheme = context.ccColorScheme;
    final config = state.config;
    final isIncome = row.type == CategoryType.income;
    final activeColor = isIncome ? PrjColors.success : scheme.error;

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
            CcCancelBtn.bouncing(
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
        CcFormLabel(text: el.tr(CcLocaleKeys.transaction_category)),
        const CcSpaceXS(),
        HorizontalFadeScrollView(
          height: context.respDim(80),
          builder: (scrollController) => ListView.separated(
            scrollDirection: Axis.horizontal,
            controller: scrollController,
            padding: EdgeInsets.zero,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const CcSpaceSM(),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = row.categoryId == category.id;

              return CcCategoryItem(
                key: ValueKey('smart_preview_cat_${row.id}_${category.id}'),
                iconCode: category.iconCode,
                iconFamily: category.iconFamily,
                nameKey: category.nameKey,
                isSelected: isSelected,
                activeColor: activeColor,
                onTap: () {
                  state.edit(
                    row.id,
                    (r) => r.copyWith(categoryId: category.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWalletSelectionSection(BuildContext context, Color activeColor) {
    if (state.wallets.isEmpty) return const SizedBox.shrink();

    final labelKey = row.type == CategoryType.income
        ? CcLocaleKeys.transaction_source_income
        : CcLocaleKeys.transaction_source_expense;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(text: el.tr(labelKey)),
        const CcSpaceXS(),
        WalletStripCard(
          wallets: state.wallets,
          selectedWalletId: row.walletId,
          activeColor: activeColor,
          defaultBgColor: context.verticalGradient(activeColor),
          onWalletSelected: (id) =>
              state.edit(row.id, (r) => r.copyWith(walletId: id)),
        ),
      ],
    );
  }

  Widget _buildDateSelectionSection(BuildContext context, Color activeColor) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final isCustomDate =
        !_isSameDay(row.date, now) && !_isSameDay(row.date, yesterday);

    return Row(
      children: [
        CcFormLabel(text: el.tr(CcLocaleKeys.transaction_time)),
        const CcSpaceSM(),
        if (isCustomDate) ...[
          _buildDatePill(
            context,
            el.DateFormat('dd/MM/yyyy').format(row.date),
            row.date,
            activeColor,
            isSelected: false,
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
    required bool isSelected,
  }) {
    final scheme = context.ccColorScheme;

    return CcText(
      label,
      textStyle: context.ccTextTheme.labelMedium?.copyWith(
        color: isSelected ? activeColor : scheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
