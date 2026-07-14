import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/util/gradient_app_bar.dart';
import '../../../category/export_category.dart';
import '../../domain/entities/budget_limit_entity.dart';
import '../../domain/entities/budget_limit_stats_entity.dart';
import '../get_x/budget_limit_controller.dart';
import '../widgets/add_budget_limit_form_sheet.dart';
import '../widgets/budget_limit_card.dart';

@RoutePage()
class BudgetLimitManagementPage extends CcGetView<BudgetLimitController> {
  const BudgetLimitManagementPage({super.key});

  @override
  bool get enableAppBar => true;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return buildDomainGradientAppBar(
      context,
      leading: CcIconButton.bouncing(
        icon: Icon(
          controller.isEditMode.value
              ? Icons.close_rounded
              : Icons.arrow_back_ios_new_rounded,
          color: context.ccColorScheme.onPrimary,
          size: context.respIconSize(baseSize: 24),
        ),
        onTap: () {
          controller.isEditMode.value = false;
          Navigator.of(context).pop();
        },
      ),
      title: Center(
        child: CcText(
          el.tr(CcLocaleKeys.budget_title),
          textStyle: context.ccTextTheme.titleMedium?.copyWith(
            color: context.ccColorScheme.onPrimary,
            fontWeight: CcTypographyParams.bold,
            fontSize: context.respFontSize(CcTypographyParams.titleMedium),
          ),
        ),
      ),
      actions: [
        CcIconButton.bouncing(
          onTap: () => _openForm(context),
          tooltip: el.tr(CcLocaleKeys.budget_add_title),
          icon: Icon(
            Icons.add_rounded,
            color: context.ccColorScheme.onPrimary,
            size: context.respIconSize(baseSize: 24),
          ),
        ),
        Obx(
          () => CcIconButton.bouncing(
            onTap: controller.toggleEditMode,
            tooltip: controller.isEditMode.value
                ? el.tr(CcLocaleKeys.common_done)
                : el.tr(CcLocaleKeys.common_edit),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                controller.isEditMode.value
                    ? Icons.check_circle_outline_rounded
                    : Icons.tune_rounded,
                key: ValueKey(controller.isEditMode.value),
                color: context.ccColorScheme.onPrimary,
                size: context.respIconSize(baseSize: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget onPageBodyWrapper(BuildContext context, Widget body) =>
      ColoredBox(color: context.ccColorScheme.background, child: body);

  @override
  Widget? get floatingActionButton => null;

  @override
  Widget? buildContent(BuildContext context) {
    // Obx here so isEditMode.value is tracked directly in the reactive context —
    // reading it inside a Builder callback (deferred build) would escape tracking.
    return Obx(() {
      final isEdit = controller.isEditMode.value;
      return Builder(
        builder: (context) => CustomScrollView(
          slivers: [
            // Always present so _BudgetLimitGrid stays at sliver-index 1 and its
            // StatefulWidget state survives mode switches.
            SliverToBoxAdapter(
              child: isEdit
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.swap_vert,
                            size: 14,
                            color: context.ccColorScheme.onSurfaceVariant
                                .withOpacity(0.5),
                          ),
                          const SizedBox(width: 6),
                          CcText(
                            el.tr(CcLocaleKeys.budget_drag_reorder_hint),
                            textStyle: context.ccTextTheme.labelSmall?.copyWith(
                              color: context.ccColorScheme.onSurfaceVariant
                                  .withOpacity(0.5),
                              fontSize: context.respFontSize(
                                CcTypographyParams.labelSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _BudgetLimitGrid(
                  key: const ValueKey('budget-limit-grid'),
                  controller: controller,
                  onOpenForm: _openForm,
                  onDelete: _confirmDelete,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _openForm(BuildContext context, {BudgetLimitEntity? editTarget}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddBudgetLimitFormSheet(editTarget: editTarget),
    );
  }

  void _confirmDelete(BuildContext context, BudgetLimitEntity budget) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(el.tr(CcLocaleKeys.budget_delete_title)),
        content: Text(
          el.tr(
            CcLocaleKeys.budget_delete_confirm,
            namedArgs: {'name': budget.name},
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
              controller.deleteBudget(budget.id);
            },
            child: Text(el.tr(CcLocaleKeys.common_delete)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Draggable grid (StatefulWidget so drag state survives reactive rebuilds)
// ─────────────────────────────────────────────────────────────────────────────

/// 2-column grid that supports hold-to-drag reorder in view mode.
///
/// Drag data carries the **item ID** (not its index), so the lookup is done
/// at drop time against the live list — no stale-capture issues when the list
/// updates mid-drag.
///
/// Drop semantics: the dragged item **swaps** positions with the item it is
/// dropped onto, giving the intuitive "move this tile to that slot" feel for
/// a fixed-slot grid layout.
class _BudgetLimitGrid extends StatefulWidget {
  final BudgetLimitController controller;
  final void Function(BuildContext, {BudgetLimitEntity? editTarget}) onOpenForm;
  final void Function(BuildContext, BudgetLimitEntity) onDelete;

  const _BudgetLimitGrid({
    super.key,
    required this.controller,
    required this.onOpenForm,
    required this.onDelete,
  });

  @override
  State<_BudgetLimitGrid> createState() => _BudgetLimitGridState();
}

class _BudgetLimitGridState extends State<_BudgetLimitGrid> {
  /// ID of the item currently being dragged; null when idle.
  String? _draggingId;

  /// ID of the item the ghost is hovering over; null when not over a target.
  String? _hoveredId;

  BudgetLimitController get _ctrl => widget.controller;

  @override
  void didUpdateWidget(_BudgetLimitGrid old) {
    super.didUpdateWidget(old);
  }

  void _startDrag(String id) => setState(() {
    _draggingId = id;
    _hoveredId = null;
  });

  void _cancelDrag() => setState(() {
    _draggingId = null;
    _hoveredId = null;
  });

  void _updateHover(String id) {
    if (_hoveredId != id) setState(() => _hoveredId = id);
  }

  void _clearHover(String id) {
    if (_hoveredId == id) setState(() => _hoveredId = null);
  }

  void _commitDrop(String fromId, String toId) {
    final budgets = _ctrl.budgets;
    final fromIdx = budgets.indexWhere((s) => s.budget.id == fromId);
    final toIdx = budgets.indexWhere((s) => s.budget.id == toId);
    if (fromIdx >= 0 && toIdx >= 0 && fromIdx != toIdx) {
      _ctrl.swapBudgets(fromIdx, toIdx);
    }
    setState(() {
      _draggingId = null;
      _hoveredId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final budgets = _ctrl.budgets;
      // Read isEditMode inside Obx so GetX tracks it as a reactive dependency.
      final isEdit = _ctrl.isEditMode.value;
      if (!isEdit && _draggingId != null) {
        // Mode switched to view while a drag was in progress — clear state.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted)
            setState(() {
              _draggingId = null;
              _hoveredId = null;
            });
        });
      }
      return GridView.builder(
        shrinkWrap: true,
        // Parent CustomScrollView handles scrolling; disable it here so the
        // LongPressDraggable gestures are not swallowed by nested scrolling.
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: context.respDim(160),
          crossAxisSpacing: context.respDim(CcPaddingParams.SPACE_MD),
          mainAxisSpacing: context.respDim(CcPaddingParams.SPACE_MD),
        ),
        itemCount: budgets.length + 1,
        itemBuilder: (context, i) {
          if (i == budgets.length) return _buildAddCell(context, isEdit);
          final stats = budgets[i];
          return isEdit
              ? _buildEditCell(context, stats)
              : _buildDraggableCell(context, stats);
        },
      );
    });
  }

  // ── View-mode cell: hold 300 ms then drag to reorder ──────────────────────

  Widget _buildDraggableCell(
    BuildContext context,
    BudgetLimitStatsEntity stats,
  ) {
    final id = stats.budget.id;
    final isDraggingThis = _draggingId == id;
    final isDropTarget = _hoveredId == id && _draggingId != null;

    return LayoutBuilder(
      builder: (ctx, constraints) => LongPressDraggable<String>(
        data: id,
        delay: const Duration(milliseconds: 300),
        onDragStarted: () => _startDrag(id),
        onDraggableCanceled: (_, _) => _cancelDrag(),
        onDragCompleted: _cancelDrag,

        // Ghost card that follows the finger.
        feedback: Material(
          color: Colors.transparent,
          elevation: 10,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Transform.scale(
              scale: 1.08,
              child: BudgetLimitGridCard(stats: stats, isDragging: true),
            ),
          ),
        ),

        // Source slot while dragging: stays in place, heavily dimmed.
        childWhenDragging: Opacity(
          opacity: 0.25,
          child: BudgetLimitGridCard(stats: stats),
        ),

        child: DragTarget<String>(
          onWillAcceptWithDetails: (d) {
            if (d.data == id) return false;
            _updateHover(id);
            return true;
          },
          onLeave: (_) => _clearHover(id),
          onAcceptWithDetails: (d) => _commitDrop(d.data, id),
          builder: (ctx, candidates, _) => AnimatedScale(
            scale: isDropTarget ? 1.07 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: isDraggingThis ? 0.25 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: BudgetLimitGridCard(key: ValueKey(id), stats: stats),
            ),
          ),
        ),
      ),
    );
  }

  // ── Edit-mode cell: static card with delete / edit badges ─────────────────

  Widget _buildEditCell(BuildContext context, BudgetLimitStatsEntity stats) {
    return BudgetLimitGridCard(
      key: ValueKey(stats.budget.id),
      stats: stats,
      isEditMode: true,
      onEdit: () => widget.onOpenForm(context, editTarget: stats.budget),
      onDelete: () => widget.onDelete(context, stats.budget),
    );
  }

  // ── "Tuỳ chỉnh danh mục" add cell ────────────────────────────────────────

  Widget _buildAddCell(BuildContext context, bool isEdit) {
    final scheme = context.ccColorScheme;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<bool>(builder: (_) => const CategorySettingsPage()),
      ),
      child: Opacity(
        opacity: isEdit ? 0.4 : 1.0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.primary.withOpacity(0.2),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_offer_outlined,
                color: scheme.onSurfaceVariant,
                size: 28,
              ),
              const SizedBox(height: 8),
              CcText(
                el.tr(CcLocaleKeys.budget_customize_category),
                textStyle: context.ccTextTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                align: Alignment.center,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
