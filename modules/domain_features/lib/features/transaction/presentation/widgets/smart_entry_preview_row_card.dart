import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/data/data_source/color/prj_color.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
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
  });

  final SmartEntryPreviewState state;
  final SmartEntryPreviewRow row;

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
        SmartEntryAmountField(
          amount: row.amount,
          currencyCode: config.currencyCode,
          hasError: row.amount <= 0,
          onChanged: (value) =>
              state.edit(row.id, (r) => r.copyWith(amount: value)),
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

  Widget _buildCategorySelectionSection(
    BuildContext context,
    Color activeColor,
  ) {
    final categories = state.categoriesFor(row.type);
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcText(
          el.tr(CcLocaleKeys.transaction_category),
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
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
        CcText(
          el.tr(labelKey),
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
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
        CcText(
          el.tr(CcLocaleKeys.transaction_time),
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const CcSpaceSM(),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (isCustomDate) ...[
                  _buildDatePill(
                    context,
                    el.DateFormat('dd/MM/yyyy').format(row.date),
                    row.date,
                    activeColor,
                    isSelected: true,
                  ),
                  const CcSpaceSM(),
                ],
                _buildDatePill(
                  context,
                  el.tr(CcLocaleKeys.transaction_today),
                  now,
                  activeColor,
                  isSelected: _isSameDay(row.date, now),
                ),
                const CcSpaceSM(),
                _buildDatePill(
                  context,
                  el.tr(CcLocaleKeys.transaction_yesterday),
                  yesterday,
                  activeColor,
                  isSelected: _isSameDay(row.date, yesterday),
                ),
                const CcSpaceSM(),
                CcBouncing(
                  onTap: () async {
                    final picked = await TransactionFormHelpers.pickDate(
                      context,
                      row.date,
                    );
                    if (picked == null) return;
                    state.edit(
                      row.id,
                      (r) => r.copyWith(
                        date: TransactionFormHelpers.updateDatePreserveTime(
                          r.date,
                          picked,
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.calendar_month,
                    size: context.respIconSize(baseSize: 18),
                    color: activeColor,
                  ),
                ),
              ],
            ),
          ),
        ),
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
    return CcBouncing(
      onTap: () {
        state.edit(
          row.id,
          (r) => r.copyWith(
            date: TransactionFormHelpers.updateDatePreserveTime(r.date, date),
          ),
        );
      },
      borderRadius: context.brLg,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.SPACE_MD),
          vertical: context.respPadding(CcPaddingParams.SPACE_XS),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: context.brLg,
          border: Border.all(
            color: isSelected ? activeColor : scheme.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: CcText(
          label,
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: isSelected ? activeColor : scheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
