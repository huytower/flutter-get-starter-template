import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/domain/entities/category_entity.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/category/prj_category_item.dart';

/// One-row category picker of the quick-entry review sheet.
///
/// Scrolls the selected category into view when the sheet opens with an
/// AI-parsed category, and whenever the selection or the list (income vs
/// expense) changes. A card that is already fully visible never moves, so
/// tapping a visible card does not shift the row under the finger.
class SmartEntryCategoryStrip extends StatefulWidget {
  const SmartEntryCategoryStrip({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.activeColor,
    required this.onSelected,
    this.itemKeyPrefix = '',
  });

  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final Color activeColor;
  final ValueChanged<CategoryEntity> onSelected;
  final String itemKeyPrefix;

  @override
  State<SmartEntryCategoryStrip> createState() =>
      _SmartEntryCategoryStripState();
}

class _SmartEntryCategoryStripState extends State<SmartEntryCategoryStrip> {
  static const double _itemWidth = 75;
  static const int _maxRevealAttempts = 6;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scheduleReveal();
  }

  @override
  void didUpdateWidget(SmartEntryCategoryStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The list is rebuilt on every edit (note typing, wallet tap): compare
    // contents, not identity, so a manual scroll is not undone by a rebuild.
    if (oldWidget.selectedCategoryId != widget.selectedCategoryId ||
        !_hasSameIds(oldWidget.categories, widget.categories)) {
      _scheduleReveal();
    }
  }

  bool _hasSameIds(List<CategoryEntity> a, List<CategoryEntity> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scheduleReveal([int attemptsLeft = _maxRevealAttempts]) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _revealSelected(attemptsLeft),
    );
  }

  void _revealSelected(int attemptsLeft) {
    if (!mounted) return;
    final index = widget.categories.indexWhere(
      (category) => category.id == widget.selectedCategoryId,
    );
    if (index < 0) return;

    if (!_scrollController.hasClients ||
        _scrollController.positions.length != 1 ||
        !_scrollController.position.hasContentDimensions ||
        _scrollController.position.viewportDimension == 0) {
      if (attemptsLeft > 0) _scheduleReveal(attemptsLeft - 1);
      return;
    }

    final position = _scrollController.position;
    final itemWidth = context.respDim(_itemWidth);
    final extent =
        itemWidth + context.respPadding(CcPaddingParams.SPACE_SM);
    final start = index * extent;
    final end = start + itemWidth;
    final viewport = position.viewportDimension;

    const tolerance = 1.0;
    final hasVisible =
        start >= position.pixels - tolerance &&
        end <= position.pixels + viewport + tolerance;
    if (hasVisible) return;

    final target = (start - (viewport - itemWidth) / 2).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemWidth = context.respDim(_itemWidth);

    return CcHorizontalFadeScrollView(
      height: context.respDim(80),
      scrollController: _scrollController,
      builder: (scrollController) => ListView.separated(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        padding: EdgeInsets.zero,
        itemCount: widget.categories.length,
        separatorBuilder: (context, index) => const CcSpaceSM(),
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          return PrjCategoryItem(
            key: ValueKey('${widget.itemKeyPrefix}${category.id}'),
            width: itemWidth,
            iconCode: category.iconCode,
            iconFamily: category.iconFamily,
            label: el.tr(category.nameKey),
            hasSelected: widget.selectedCategoryId == category.id,
            activeColor: widget.activeColor,
            onTap: () => widget.onSelected(category),
          );
        },
      ),
    );
  }
}
