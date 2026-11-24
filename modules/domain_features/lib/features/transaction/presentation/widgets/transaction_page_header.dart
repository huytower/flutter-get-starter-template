import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/di/di.dart';
import 'package:domain_features/features/transaction/presentation/widgets/transaction_header_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../get_x/expense_form_controller.dart';
import '../get_x/quick_entry_session.dart';
import '../get_x/transaction_controller.dart';
import '../get_x/transaction_form_controller.dart';
import 'transaction_header_actions.dart';
import 'transaction_header_title.dart';

class TransactionPageHeader extends StatelessWidget {
  const TransactionPageHeader({
    required this.controller,
    this.onOpenNotification,
    this.onOpenReport,
    this.onSubmit,
    this.expenseFormController,
    this.onInlineRowHeightChanged,
  });

  final TransactionController controller;
  final VoidCallback? onOpenNotification;
  final VoidCallback? onOpenReport;
  final VoidCallback? onSubmit;
  final ExpenseFormController? expenseFormController;

  /// Reports the height of the one-row header content (see [useInlineLayout])
  /// so the page can size the header to it instead of a screen percentage.
  final ValueChanged<double>? onInlineRowHeightChanged;

  @override
  Widget build(BuildContext context) {
    final hasDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = context.ccColorScheme;
    final assetPath = hasDark
        ? 'assets/bg/bg_header_dark.webp'
        : 'assets/bg/bg_header_light.webp';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (hasDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: scheme.background,
            systemNavigationBarIconBrightness: hasDark
                ? Brightness.light
                : Brightness.dark,
          ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            // Square where the header meets the navigation rail, so it reads
            // as one surface with the rail instead of a floating card.
            bottomLeft: CcNavigationRailScope.railVisibleOf(context)
                ? Radius.zero
                : Radius.circular(context.respDim(16)),
            bottomRight: Radius.circular(context.respDim(16)),
          ),
          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        // Background full-bleed, foreground capped on wide windows.
        child: CcMaxWidth.content(
          child: useInlineLayout(context)
              ? _buildInlineForeground(context)
              : _buildHeroForeground(context),
        ),
      ),
    );
  }

  /// Wide but short windows (tablet / iPad in landscape, ≥ 840 dp wide and
  /// < 900 dp tall): title, banner and actions share one row so the header
  /// stays low and the tab bar never covers the banner.
  static bool useInlineLayout(BuildContext context) =>
      context.windowSizeClass.isAtLeast(CcWindowSizeClass.expanded) &&
      !context.windowHeightClass.isAtLeast(CcWindowHeightClass.expanded);

  Widget _buildInlineForeground(BuildContext context) {
    final guideline = getIt<GuidelineProvider>();

    // Laid out at its natural height (never squeezed by the header box) and
    // measured, so the page sizes the header to its content.
    return OverflowBox(
      alignment: Alignment.topCenter,
      minHeight: 0,
      maxHeight: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top),
          const CcSpaceMD(),
          CcMeasureSize(
            onChange: (size) => onInlineRowHeightChanged?.call(size.height),
            child: CcSymmetricPadding(
              horizontal: CcPaddingParams.PAGE_MD,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TransactionHeaderTitle(
                    controller: controller,
                    quickEntryControllerFor: _quickEntryControllerFor,
                    flex: 2,
                  ),
                  const CcSpaceMD(),
                  Expanded(
                    flex: 3,
                    child: TransactionHeaderBanner(
                      controller: controller,
                      guideline: guideline,
                      expenseFormController: expenseFormController,
                      // One line only: a wrapped description would not fit.
                      hideGuidelineDescription: true,
                    ),
                  ),
                  const CcSpaceSM(),
                  TransactionHeaderActions(
                    controller: controller,
                    onSubmit: onSubmit,
                    onOpenReport: onOpenReport,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroForeground(BuildContext context) {
    final guideline = getIt<GuidelineProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (MediaQuery.of(context).padding.top > 0)
          SizedBox(height: MediaQuery.of(context).padding.top),

        const CcSpaceMD(),
        CcSymmetricPadding(
          horizontal: CcPaddingParams.PAGE_MD,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TransactionHeaderTitle(
                controller: controller,
                quickEntryControllerFor: _quickEntryControllerFor,
              ),
              TransactionHeaderActions(
                controller: controller,
                onSubmit: onSubmit,
                onOpenReport: onOpenReport,
              ),
            ],
          ),
        ),
        const CcSpaceXS(),
        CcSymmetricPadding(
          horizontal: CcPaddingParams.PAGE_MD,
          child: TransactionHeaderBanner(
            controller: controller,
            guideline: guideline,
            expenseFormController: expenseFormController,
          ),
        ),
      ],
    );
  }

  QuickEntrySession? _quickEntryControllerFor(TransactionTabKind tab) {
    final TransactionFormController? form =
        (tab == TransactionTabKind.expense && expenseFormController != null)
        ? expenseFormController
        : controller.getQuickEntryControllerForTab(tab);
    return form?.quickEntry;
  }
}
