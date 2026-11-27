import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/presentation/widgets/money_keypad_panel.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/di/di.dart';
import '../../../../core/get_x/prj_get_view.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../report/presentation/get_x/report_controller.dart';
import '../../../wallet/presentation/widgets/wallet_display_name.dart';
import '../get_x/reconciliation_controller.dart';
import '../widgets/reconciliation_closed_cycle_body.dart';
import '../widgets/reconciliation_confirm_button.dart';
import '../widgets/reconciliation_description_banner.dart';
import '../widgets/reconciliation_history_section.dart';
import '../widgets/reconciliation_mismatch_warning.dart';
import '../widgets/reconciliation_summary.dart';
import '../widgets/wallet_reconcile_tile.dart';

@RoutePage()
class ReconcilePage extends PrjGetView<ReconciliationController> {
  const ReconcilePage({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return CcGradientAppBar.create(
      context,
      leading: CcIconButton.bouncing(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: context.ccColorScheme.onPrimary,
          size: context.respIconSize(baseSize: 24),
        ),
        onTap: () => Navigator.of(context).pop(),
      ),
      title: CcText(
        el.tr(PrjLocaleKeys.reconciliation_title),
        textStyle: context.ccTextTheme.titleMedium?.copyWith(
          color: context.ccColorScheme.onPrimary,
          fontWeight: CcTypographyParams.bold,
        ),
      ),
      // No confirm action here: the inline ReconciliationConfirmButton under
      // the summary is the single place to confirm.
    );
  }

  /// The base retry calls `onInit()`, which only registers listeners for this
  /// controller — reload the data instead.
  @override
  void onRetry(BuildContext context) {
    controller.loadBalances();
    controller.loadHistory();
  }

  /// Mint gradient + finance line art behind the whole body.
  @override
  Widget onPageBodyWrapper(BuildContext context, Widget body) {
    return Stack(
      children: [
        const Positioned.fill(child: CcFinanceLineArtBackground()),
        body,
      ],
    );
  }

  @override
  Widget? buildContent(BuildContext context) {
    return Obx(() {
      // A closed cycle (reached through "View history", or just confirmed)
      // must not offer another reconciliation.
      if (controller.cycle.value?.hasReconciledThisCycle ?? false) {
        return const ReconciliationClosedCycleBody();
      }
      // The keypad always sits under the content (never as an extra column),
      // so the tablet keeps its two-column body; the keypad itself is compact
      // on tablets (see CcNumericKeypad).
      return Column(
        children: [
          Expanded(child: _buildScrollBody(context)),
          _buildBottomSlot(context),
        ],
      );
    });
  }

  Widget _buildKeypad(BuildContext context) {
    return MoneyKeypadPanel(
      onKeyPress: controller.updateAmount,
      onDelete: controller.deleteChar,
      onClear: controller.clearAmount,
      suggestions: MoneyConstants.getReconciliationQuickAmounts(
        currencyCode: controller.currencyCode,
      ),
      onSuggestion: (value) => controller.setAmount(value),
      onDone: controller.stopEditing,
      activeColor: context.ccColorScheme.primary,
    );
  }

  /// Small tablet and up: the keypad floats over the page instead of pushing
  /// the content up.
  bool _floatingKeypad(BuildContext context) =>
      context.windowSizeClass.hasAtLeast(CcWindowSizeClass.medium);

  /// Bottom room kept free while the floating keypad is up (chips + 4 key rows).
  static const double _floatingKeypadReserve = 280;

  Widget _buildScrollBody(BuildContext context) {
    final base = context.respPadding(CcPaddingParams.PAGE_SM);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: controller.stopEditing,
      child: Obx(() {
        final reserve =
            _floatingKeypad(context) && controller.editingWalletId.value != null
            ? _floatingKeypadReserve
            : 0.0;
        return ListView(
          padding: EdgeInsets.fromLTRB(base, base, base, base + reserve),
          children: CcTwoColumn.shouldUse(context)
              ? _buildTwoColumnChildren(context)
              : [
                  const ReconciliationDescriptionBanner(),
                  _buildInstructionText(context),
                  _buildWalletTiles(context),
                  const ReconciliationMismatchWarning(),
                  const CcSpaceXS(),
                  const ReconciliationSummary(),
                  const CcSpaceXS(),
                  const ReconciliationConfirmButton(),
                  const ReconciliationHistorySection(),
                ],
        );
      }),
    );
  }

  /// Landscape tablet, two columns (3.5:1.5): the wallet tiles (the thing being
  /// counted) flow across two sub-columns on the left; the totals, mismatch
  /// warning, confirm button and history fill the right.
  List<Widget> _buildTwoColumnChildren(BuildContext context) {
    return [
      const ReconciliationDescriptionBanner(),
      // Own Row instead of CcTwoColumn: that widget forces a 1:1 split on small
      // tablets, but this page always wants 3.5:1.5 (flex 7:3).
      CcMaxWidth(
        maxWidth: CcTwoColumn.defaultMaxWidth,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInstructionText(context),
                  _buildWalletTiles(context, columns: 2),
                ],
              ),
            ),
            SizedBox(width: context.respPadding(CcPaddingParams.SPACE_MD)),
            const Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReconciliationMismatchWarning(),
                  CcSpaceXS(),
                  ReconciliationSummary(),
                  CcSpaceXS(),
                  ReconciliationConfirmButton(),
                  ReconciliationHistorySection(),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildInstructionText(BuildContext context) {
    return CcPadding(
      CcText(
        el.tr(PrjLocaleKeys.reconciliation_instruction),
        textStyle: context.ccTextTheme.labelMedium?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
      CcPaddingParams.SPACE_XS,
      0,
      0,
      CcPaddingParams.SPACE_SM,
    );
  }

  /// The wallet tiles: one per row, or flowing across [columns] columns.
  Widget _buildWalletTiles(BuildContext context, {int columns = 1}) {
    final tiles = controller.balances.map((balance) {
      return WalletReconcileTile(
        balance: balance,
        onActualChanged: (value) =>
            controller.setActual(balance.wallet.id, value),
        onAcknowledge: () =>
            controller.acknowledgeAdjustment(balance.wallet.id),
        onReview: () => _openWalletReview(
          context,
          balance.wallet.id,
          balance.wallet.displayName(context),
        ),
      );
    }).toList();
    if (columns > 1) return CcMultiColumn(columns: columns, children: tiles);
    return Column(children: tiles);
  }

  /// Shows the money keypad while a wallet amount is being edited.
  ///
  /// The confirm button lives inline under the summary rows, so when the
  /// keypad is hidden this slot only reserves the system safe area — a
  /// device-dependent inset, not a spacing token, hence the raw [SizedBox].
  Widget _buildBottomSlot(BuildContext context) {
    return Obx(() {
      if (controller.editingWalletId.value == null) {
        return const SizedBox.shrink();
      }

      return SafeArea(top: false, child: _buildKeypad(context));
    });
  }
}

/// Opens the Report page pre-filtered to [walletId] and scrolled to the
/// daily transaction detail table, so the user can review that wallet's
/// income/expense entries before committing a reconciliation adjustment.
///
/// [ReportController] is a long-lived GetX singleton (see [PrjGetView.build]),
/// so its filter must be set on the live instance before the route is
/// pushed rather than passed as a route param — the same pattern other
/// report entry points already use to force a refresh on re-entry.
void _openWalletReview(
  BuildContext context,
  String walletId,
  String walletName,
) {
  final alreadyRegistered = Get.isRegistered<ReportController>();
  final report = alreadyRegistered
      ? Get.find<ReportController>()
      : getIt<ReportController>();

  report.setWalletFilter(walletId, walletName);
  report.requestScrollToDaily();

  if (alreadyRegistered) {
    report.load(showLoading: false);
  } else {
    Get.put(report);
  }

  context.router.push(const ReportRoute());
}
