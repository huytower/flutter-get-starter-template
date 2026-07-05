import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../domain/entities/budget_entity.dart';
import '../get_x/budget_controller.dart';
import '../widgets/budget_card.dart';
import '../widgets/budget_form_sheet.dart';

@RoutePage()
class BudgetPage extends CcGetView<BudgetController> {
  const BudgetPage({super.key});

  @override
  bool get enableAppBar => true;

  @override
  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      title: Builder(
        builder: (context) => CcText(
          el.tr(CcLocaleKeys.budget_title),
          textStyle: context.ccTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Get.context?.ccColorScheme.primary,
      elevation: 0,
    );
  }

  @override
  Widget? get floatingActionButton => Builder(
    builder: (context) => CcFloatingActionButton(
      iconData: Icons.add,
      onTap: () => _openForm(context),
    ),
  );

  @override
  Widget? buildContent() {
    return Builder(
      builder: (context) {
        if (controller.budgets.isEmpty) {
          return Center(
            child: CcText(
              el.tr(CcLocaleKeys.budget_empty),
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                color: context.ccColorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.all(
            context.respPadding(CcPaddingParams.SPACE_MD),
          ),
          children: controller.budgets
              .map(
                (stats) => BudgetCard(
                  stats: stats,
                  onEditLimit: () => _editLimit(context, stats.budget),
                  onReset: () => _openForm(context, resetTarget: stats.budget),
                  onDelete: () => _confirmDelete(context, stats.budget),
                ),
              )
              .toList(),
        );
      },
    );
  }

  void _openForm(BuildContext context, {BudgetEntity? resetTarget}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BudgetFormSheet(resetTarget: resetTarget),
    );
  }

  void _editLimit(BuildContext context, BudgetEntity budget) {
    final initialText = budget.limit.toString();
    final limitController = TextEditingController(text: initialText)
      ..selection = TextSelection(
        baseOffset: 0,
        extentOffset: initialText.length,
      );
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(el.tr(CcLocaleKeys.budget_edit_limit)),
        content: TextField(
          controller: limitController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(suffixText: 'đ'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(el.tr(CcLocaleKeys.common_cancel)),
          ),
          TextButton(
            onPressed: () async {
              final value = int.tryParse(limitController.text.trim());
              Navigator.pop(dialogContext);
              if (value != null) {
                await controller.updateLimit(budget.id, value);
              }
            },
            child: Text(el.tr(CcLocaleKeys.common_save)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, BudgetEntity budget) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(el.tr(CcLocaleKeys.budget_delete_title)),
        content: Text(
          el.tr(CcLocaleKeys.budget_delete_confirm, namedArgs: {'name': budget.name}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(el.tr(CcLocaleKeys.common_cancel)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              controller.deleteBudget(budget.id);
            },
            child: Text(el.tr(CcLocaleKeys.common_delete)),
          ),
        ],
      ),
    );
  }
}
