import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../get_x/liability_base_form_controller.dart';

/// Borrow/Repay pill switch shown at the top of the Liability form.
class BorrowDirectionToggle extends StatefulWidget {
  final LiabilityDirectionForm value;
  final Color activeColor;
  final ValueChanged<LiabilityDirectionForm> onChanged;

  const BorrowDirectionToggle({
    super.key,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  State<BorrowDirectionToggle> createState() => _BorrowDirectionToggleState();
}

class _BorrowDirectionToggleState extends State<BorrowDirectionToggle>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
    initialIndex: _indexOf(widget.value),
  );

  static int _indexOf(LiabilityDirectionForm action) =>
      action == LiabilityDirectionForm.increase ? 0 : 1;

  @override
  void didUpdateWidget(covariant BorrowDirectionToggle oldWidget) {
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

    final firstLabel = el.tr(
      CcLocaleKeys.transaction_liability_direction_borrow,
    );
    final secondLabel = el.tr(CcLocaleKeys.transaction_record_repay);

    return Center(
      child: SizedBox(
        // 60% of a phone width; capped so it stays a compact toggle on
        // tablets and beside the rail.
        width: (MediaQuery.sizeOf(context).width * 0.6).clamp(
          0.0,
          context.respDim(240),
        ),
        child: Container(
          height: context.respDim(35),
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
                  ? LiabilityDirectionForm.increase
                  : LiabilityDirectionForm.decrease,
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
              _buildTab(context, firstLabel, 0),
              _buildTab(context, secondLabel, 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String text, int index) {
    return Tab(child: Text(text));
  }
}
