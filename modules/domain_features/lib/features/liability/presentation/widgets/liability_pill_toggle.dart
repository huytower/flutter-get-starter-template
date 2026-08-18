import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// Generic 2-option pill switch — same [TabBar]-in-a-shadowed-pill
/// construction as [TransactionTabBar]/`InvestmentDirectionToggle`, reused
/// here for the Loan form's three toggles (mode, direction, repayment
/// method) instead of duplicating the boilerplate per concept.
class LiabilityPillToggle extends StatefulWidget {
  final int selectedIndex;
  final String firstLabel;
  final String secondLabel;
  final Color activeColor;
  final ValueChanged<int> onChanged;

  const LiabilityPillToggle({
    super.key,
    required this.selectedIndex,
    required this.firstLabel,
    required this.secondLabel,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  State<LiabilityPillToggle> createState() => _LiabilityPillToggleState();
}

class _LiabilityPillToggleState extends State<LiabilityPillToggle>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
    initialIndex: widget.selectedIndex,
  );

  @override
  void didUpdateWidget(covariant LiabilityPillToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_tabController.index != widget.selectedIndex) {
      _tabController.animateTo(widget.selectedIndex);
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
        onTap: widget.onChanged,
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
        tabs: [Tab(text: widget.firstLabel), Tab(text: widget.secondLabel)],
      ),
    );
  }
}

