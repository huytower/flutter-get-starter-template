import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../domain/entities/investment_direction.dart';

/// Chi ra / Thu vào pill switch shown at the top of the Investment form —
/// same [TabBar]-in-a-shadowed-pill construction as [TransactionTabBar]
/// above it, so the two read as one consistent tab language.
class InvestmentDirectionToggle extends StatefulWidget {
  final InvestmentDirection value;
  final Color activeColor;
  final ValueChanged<InvestmentDirection> onChanged;

  const InvestmentDirectionToggle({
    super.key,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  State<InvestmentDirectionToggle> createState() =>
      _InvestmentDirectionToggleState();
}

class _InvestmentDirectionToggleState extends State<InvestmentDirectionToggle>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
    initialIndex: _indexOf(widget.value),
  );

  static int _indexOf(InvestmentDirection direction) =>
      direction == InvestmentDirection.contribute ? 0 : 1;

  @override
  void didUpdateWidget(covariant InvestmentDirectionToggle oldWidget) {
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
                  ? InvestmentDirection.contribute
                  : InvestmentDirection.returnProfit,
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
              _buildTab(
                el.tr(PrjLocaleKeys.transaction_investment_contribution),
              ),
              _buildTab(el.tr(PrjLocaleKeys.transaction_investment_return)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text) {
    return Tab(child: Text(text));
  }
}
