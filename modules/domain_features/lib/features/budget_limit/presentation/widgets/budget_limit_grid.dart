import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../category/export_category.dart';
import '../../domain/entities/budget_limit_entity.dart';
import '../../domain/entities/budget_limit_stats_entity.dart';
import '../get_x/budget_limit_controller.dart';
import 'budget_limit_grid_card.dart';

/// 2-column grid that supports hold-to-drag reorder in view mode.
///
/// Drag data carries the **item ID** (not its index), so the lookup is done
/// at drop time against the live list — no stale-capture issues when the list
/// updates mid-drag.
///
/// Drop semantics: the dragged item **swaps** positions with the item it is
/// dropped onto, giving the intuitive "move this tile to that slot" feel for
/// a fixed-slot grid layout.
class BudgetLimitGrid extends StatefulWidget {
  final BudgetLimitController controller;
  final void Function(BuildContext, {BudgetLimitEntity? editTarget}) onOpenForm;
  final void Function(BuildContext, BudgetLimitEntity) onDelete;

  const BudgetLimitGrid({
    super.key,
    required this.controller,
    required this.onOpenForm,
    required this.onDelete,
  });

  @override
  State<BudgetLimitGrid> createState() => _BudgetLimitGridState();
}

class _BudgetLimitGridState extends State<BudgetLimitGrid> {
  /// ID of the item currently being dragged; null when idle.
  String? _draggingId;

  /// ID of the item the ghost is hovering over; null when not over a target.
  String? _hoveredId;

  BudgetLimitController get _ctrl => widget.controller;

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
          if (mounted) {
            setState(() {
              _draggingId = null;
              _hoveredId = null;
            });
          }
        });
      }
      return GridView.builder(
        shrinkWrap: true,
        // Parent CustomScrollView handles scrolling; disable it here so the
        // LongPressDraggable gestures are not swallowed by nested scrolling.
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: context.respDim(110),
          crossAxisSpacing: context.respDim(CcPaddingParams.PAGE_XS),
          mainAxisSpacing: context.respDim(CcPaddingParams.PAGE_XS),
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
          borderRadius: context.brLg,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Transform.scale(
              scale: 0.9,
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
    return CcInkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<bool>(builder: (_) => const CategorySettingsPage()),
      ),
      borderRadius: context.brLg,
      child: Opacity(
        opacity: isEdit ? 0.4 : 1.0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: context.brLg,
            border: Border.all(
              color: scheme.onSurface.withOpacity(0.06),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_offer_outlined,
                color: scheme.onSurfaceVariant.withOpacity(0.5),
                size: 28,
              ),
              const CcSpaceSM(),
              CcText(
                el.tr(CcLocaleKeys.budget_customize_category),
                textStyle: context.ccTextTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant.withOpacity(0.5),
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
