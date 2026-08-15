import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/money_format_helper.dart';
import '../../../../core/helper/wallet_icon_helper.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../domain/entities/transaction_template_entity.dart';
import '../get_x/transaction_template_controller.dart';
import 'add_transaction_template_sheet.dart';

/// Horizontal "Mẫu nhanh" (Quick templates) chip strip on the Expense form.
/// Tapping a chip pre-fills the form via [onApply]; the user still confirms
/// with the form's own Save button — nothing is submitted directly from
/// here, matching how every other pre-fill flow in this app (edit mode,
/// reconciliation adjustments) works.
class TransactionTemplateChipList extends StatefulWidget {
  final Color activeColor;
  final List<WalletEntity> wallets;
  final void Function(TransactionTemplateEntity template) onApply;

  const TransactionTemplateChipList({
    super.key,
    required this.activeColor,
    required this.wallets,
    required this.onApply,
  });

  @override
  State<TransactionTemplateChipList> createState() =>
      _TransactionTemplateChipListState();
}

class _TransactionTemplateChipListState
    extends State<TransactionTemplateChipList> {
  final _controller = Get.isRegistered<TransactionTemplateController>()
      ? Get.find<TransactionTemplateController>()
      : Get.put(getIt<TransactionTemplateController>());

  @override
  void initState() {
    super.initState();
    _controller.loadTemplates();
  }

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddTransactionTemplateSheet(wallets: widget.wallets),
    );
  }

  void _confirmDelete(BuildContext context, TransactionTemplateEntity t) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(el.tr(CcLocaleKeys.transaction_template_delete_title)),
        content: Text(
          el.tr(
            CcLocaleKeys.transaction_template_delete_confirm,
            namedArgs: {'name': t.name},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(el.tr(CcLocaleKeys.common_cancel)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _controller.deleteTemplate(t.id);
            },
            child: Text(el.tr(CcLocaleKeys.common_delete)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final templates = _controller.templates.toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          const CcSpaceXS(),
          HorizontalFadeScrollView(
            height: context.respDim(56),
            builder: (scrollController) => ListView.separated(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
              ),
              itemCount: templates.length + 1,
              separatorBuilder: (_, _) => const CcSpaceSM(),
              itemBuilder: (context, index) {
                if (index == templates.length) {
                  return _buildAddChip(context);
                }
                return _buildTemplateChip(context, templates[index]);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTitle(BuildContext context) {
    return CcSymmetricPadding(
      horizontal: CcPaddingParams.PAGE_SM,
      child: CcText(
        el.tr(CcLocaleKeys.transaction_template_title),
        textStyle: context.ccTextTheme.labelMedium?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTemplateChip(BuildContext context, TransactionTemplateEntity t) {
    final scheme = context.ccColorScheme;

    return CcInkWell(
      onTap: () => widget.onApply(t),
      onLongPress: () => _confirmDelete(context, t),
      borderRadius: context.brLg,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.respDim(12),
          vertical: context.respDim(8),
        ),
        decoration: BoxDecoration(
          color: scheme.onSurface.withAlpha(10),
          borderRadius: context.brLg,
          border: Border.all(
            color: scheme.onSurface.withAlpha(10),
            width: context.respDim(1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CcIcon(
              icon: iconDataFromCode(
                t.categoryIconCode ?? Icons.receipt_long_rounded.codePoint,
                fontFamily: t.categoryIconFamily,
              ),
              size: context.respIconSize(baseSize: 16),
              color: widget.activeColor,
            ),
            const CcSpaceXS(),
            CcText(
              '${t.name} · ${formatVndShort(t.amount)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textStyle: context.ccTextTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddChip(BuildContext context) {
    return CcInkWell(
      onTap: () => _openAddSheet(context),
      borderRadius: context.brLg,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.respDim(12),
          vertical: context.respDim(8),
        ),
        decoration: BoxDecoration(
          borderRadius: context.brLg,
          border: Border.all(
            color: widget.activeColor.withAlpha(60),
            width: context.respDim(1),
          ),
        ),
        child: Icon(
          Icons.add_rounded,
          size: context.respIconSize(baseSize: 18),
          color: widget.activeColor,
        ),
      ),
    );
  }
}
