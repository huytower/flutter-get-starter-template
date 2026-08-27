import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../domain/entities/liability_entity.dart';
import '../get_x/liability_base_form_controller.dart';

/// Borrow/Repay or Lend/Collect pill switch shown at the top of the Liability forms.
class LiabilityActionToggle extends StatefulWidget {
  final LiabilityFormAction value;
  final String direction; // LiabilityDirection.borrow or lend
  final Color activeColor;
  final ValueChanged<LiabilityFormAction> onChanged;

  const LiabilityActionToggle({
    super.key,
    required this.value,
    required this.direction,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  State<LiabilityActionToggle> createState() => _LiabilityActionToggleState();
}

class _LiabilityActionToggleState extends State<LiabilityActionToggle>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
    initialIndex: _indexOf(widget.value),
  );

  static int _indexOf(LiabilityFormAction action) =>
      action == LiabilityFormAction.increase ? 0 : 1;

  @override
  void didUpdateWidget(covariant LiabilityActionToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    final index = _indexOf(widget.value);
    if (_tabController.index != index) {
      _tabController.animateTo(index);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final isBorrow = widget.direction == LiabilityDirection.borrow;

    final firstLabel = isBorrow
        ? el.tr(CcLocaleKeys.transaction_liability_direction_borrow)
        : el.tr(CcLocaleKeys.transaction_liability_direction_lend);
    final secondLabel = isBorrow
        ? el.tr(CcLocaleKeys.transaction_record_repay)
        : el.tr(CcLocaleKeys.transaction_record_collect);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
      ),
      height: context.respDim(40),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: context.brLg,
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withOpacity(0.12),
            blurRadius: context.respDim(12),
            offset: Offset(0, context.respDim(6)),
          ),
        ],
      ),
      padding: EdgeInsets.all(context.respDim(4)),
      child: TabBar(
        controller: _tabController,
        onTap: (index) => widget.onChanged(
          index == 0
              ? LiabilityFormAction.increase
              : LiabilityFormAction.decrease,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        indicator: BoxDecoration(
          color: widget.activeColor.withOpacity(0.08),
          borderRadius: context.brLg,
        ),
        labelColor: widget.activeColor,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: context.ccTextTheme.labelMedium?.copyWith(
          fontWeight: CcTypographyParams.bold,
        ),
        labelPadding: EdgeInsets.zero,
        tabs: [
          Tab(text: firstLabel),
          Tab(text: secondLabel),
        ],
      ),
    );
  }
}
