import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../report/presentation/get_x/report_controller.dart';
import '../../../transaction/presentation/widgets/money_keypad_panel.dart';
import '../../../wallet/presentation/widgets/wallet_display_name.dart';
import '../get_x/reconciliation_controller.dart';
import '../widgets/finance_line_art_background.dart';
import '../widgets/reconciliation_confirm_button.dart';
import '../widgets/reconciliation_guide_sheet.dart';
import '../widgets/reconciliation_history_section.dart';
import '../widgets/reconciliation_mismatch_warning.dart';
import '../widgets/reconciliation_summary.dart';
import '../widgets/wallet_reconcile_tile.dart';

@RoutePage()
class ReconcilePage extends CcGetView<ReconciliationController> {
  const ReconcilePage({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return buildDomainGradientAppBar(
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
        el.tr(CcLocaleKeys.reconciliation_title),
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
        const Positioned.fill(child: FinanceLineArtBackground()),
        body,
      ],
    );
  }

  @override
  Widget? buildContent(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          Expanded(child: _buildScrollBody(context)),
          _buildBottomSlot(context),
        ],
      );
    });
  }

  Widget _buildScrollBody(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: controller.stopEditing,
      child: ListView(
        padding: EdgeInsets.all(context.respPadding(CcPaddingParams.PAGE_SM)),
        children: CcTwoColumn.shouldUse(context)
            ? _buildTwoColumnChildren(context)
            : [
                _buildSeeMoreDescription(context),
                _buildInstructionText(context),
                _buildWalletTiles(context),
                const ReconciliationMismatchWarning(),
                const CcSpaceXS(),
                const ReconciliationSummary(),
                const CcSpaceXS(),
                const ReconciliationConfirmButton(),
                const ReconciliationHistorySection(),
              ],
      ),
    );
  }

  /// Landscape tablet, three columns: the wallet tiles (the thing being
  /// counted) flow across the two left columns; the totals, mismatch warning,
  /// confirm button and history fill the third.
  List<Widget> _buildTwoColumnChildren(BuildContext context) {
    return [
      _buildSeeMoreDescription(context),
      CcTwoColumn(
        leftFlex: 2,
        rightFlex: 1,
        left: [
          _buildInstructionText(context),
          _buildWalletTiles(context, columns: 2),
        ],
        right: [
          const ReconciliationMismatchWarning(),
          const CcSpaceXS(),
          const ReconciliationSummary(),
          const CcSpaceXS(),
          const ReconciliationConfirmButton(),
          const ReconciliationHistorySection(),
        ],
      ),
    ];
  }

  Widget _buildInstructionText(BuildContext context) {
    return CcPadding(
      CcText(
        el.tr(CcLocaleKeys.reconciliation_instruction),
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

  Widget _buildSeeMoreDescription(BuildContext context) {
    // The one-line preview is plain text: drop the `**keyword**` markers that
    // the guide sheet turns into emphasis.
    final text = el
        .tr(CcLocaleKeys.reconciliation_description_line_1)
        .replaceAll('**', '');
    return CcBouncing(
      onTap: () => ReconciliationGuideSheet.show(context),
      borderRadius: context.brSm,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.SPACE_SM),
          vertical: context.respPadding(CcPaddingParams.SPACE_XS),
        ),
        decoration: BoxDecoration(
          color: context.ccColorScheme.onSurface.withOpacity(0.05),
          borderRadius: context.brSm,
        ),
        child: Row(
          children: [
            Expanded(
              child: CcText(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textStyle: context.ccTextTheme.labelSmall?.copyWith(
                  color: context.ccColorScheme.onSurfaceVariant.withOpacity(
                    0.5,
                  ),
                  fontSize: context.respFontSize(9),
                ),
              ),
            ),
            const CcSpaceXS(),
            CcText(
              el.tr(CcLocaleKeys.wallet_see_all),
              textStyle: context.ccTextTheme.labelSmall?.copyWith(
                color: context.ccColorScheme.primary,
                fontSize: context.respFontSize(9),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
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

      return SafeArea(
        top: false,
        child: MoneyKeypadPanel(
          onKeyPress: controller.updateAmount,
          onDelete: controller.deleteChar,
          onClear: controller.clearAmount,
          suggestions: MoneyConstants.getReconciliationQuickAmounts(
            currencyCode: controller.currencyCode,
          ),
          onSuggestion: (value) => controller.setAmount(value),
          onDone: controller.stopEditing,
          activeColor: context.ccColorScheme.primary,
        ),
      );
    });
  }
}

/// Opens the Report page pre-filtered to [walletId] and scrolled to the
/// daily transaction detail table, so the user can review that wallet's
/// income/expense entries before committing a reconciliation adjustment.
///
/// [ReportController] is a long-lived GetX singleton (see [CcGetView.build]),
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
