import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../get_x/lend_form_controller.dart';

/// Lend/Collect pill switch shown at the top of the Lend form.
class LendDirectionToggle extends StatefulWidget {
  final LendDirectionForm value;
  final Color activeColor;
  final ValueChanged<LendDirectionForm> onChanged;

  const LendDirectionToggle({
    super.key,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  State<LendDirectionToggle> createState() => _LendDirectionToggleState();
}

class _LendDirectionToggleState extends State<LendDirectionToggle>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
    initialIndex: _indexOf(widget.value),
  );

  static int _indexOf(LendDirectionForm action) =>
      action == LendDirectionForm.increase ? 0 : 1;

  @override
  void didUpdateWidget(covariant LendDirectionToggle oldWidget) {
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

    final firstLabel = el.tr(CcLocaleKeys.transaction_liability_direction_lend);
    final secondLabel = el.tr(CcLocaleKeys.transaction_record_collect);

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
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
                  ? LendDirectionForm.increase
                  : LendDirectionForm.decrease,
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
              _buildTab(context, firstLabel),
              _buildTab(context, secondLabel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String text) {
    return Tab(
      child: Text(text),
    );
  }
}
