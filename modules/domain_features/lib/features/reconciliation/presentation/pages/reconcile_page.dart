import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../report/presentation/get_x/report_controller.dart';
import '../../../transaction/presentation/widgets/money_keypad_panel.dart';
import '../get_x/reconciliation_controller.dart';
import '../widgets/reconciliation_confirm_button.dart';
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
      actions: [
        Builder(
          builder: (context) => Obx(() {
            final enabled =
                !controller.isSubmitting.value &&
                controller.unhandledCount.value == 0 &&
                controller.balances.isNotEmpty;
            return CcIconButton.bouncing(
              icon: Icon(
                Icons.handshake_outlined,
                size: context.respIconSize(baseSize: 20),
                color: context.ccColorScheme.onPrimary,
              ),
              tooltip: el.tr(CcLocaleKeys.reconciliation_confirm),
              onTap: enabled
                  ? () => controller.confirmReconciliation(context)
                  : () {},
              isEnable: enabled,
              useDebounce: true,
            );
          }),
        ),
        const CcSpaceSM(),
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
        padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
        children: [
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
    final text = el.tr(CcLocaleKeys.reconciliation_description_line_1);
    return CcBouncing(
      onTap: () => CcDialogHelper.showMessageBottomSheet(
        context: context,
        title: el.tr(CcLocaleKeys.reconciliation_title),
        isOnlyConfirm: true,
        customWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDescriptionItem(
              context,
              icon: Icons.info_outline_rounded,
              text: el.tr(CcLocaleKeys.reconciliation_description_line_1),
            ),
            const CcSpaceMD(),
            _buildDescriptionItem(
              context,
              icon: Icons.sync_alt_rounded,
              text: el.tr(CcLocaleKeys.reconciliation_description_line_2),
            ),
            const CcSpaceMD(),
            _buildDescriptionItem(
              context,
              icon: Icons.event_repeat_rounded,
              text: el.tr(CcLocaleKeys.reconciliation_cycle_subtitle),
            ),
          ],
        ),
      ),
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
              '... See more',
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

  Widget _buildDescriptionItem(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final scheme = context.ccColorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(context.respDim(6)),
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: context.respIconSize(baseSize: 18),
            color: scheme.primary,
          ),
        ),
        const CcSpaceSM(),
        Expanded(
          child: CcText(
            text,
            maxLines: 10,
            textAlign: TextAlign.start,
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletTiles(BuildContext context) {
    return Column(
      children: controller.balances.map((balance) {
        return WalletReconcileTile(
          balance: balance,
          onActualChanged: (value) =>
              controller.setActual(balance.wallet.id, value),
          onAcknowledge: () =>
              controller.acknowledgeAdjustment(balance.wallet.id),
          onReview: () => _openWalletReview(
            context,
            balance.wallet.id,
            balance.wallet.name,
          ),
        );
      }).toList(),
    );
  }

  /// Shows the money keypad while a wallet amount is being edited.
  ///
  /// The confirm button lives inline under the summary rows, so when the
  /// keypad is hidden this slot only reserves the system safe area — a
  /// device-dependent inset, not a spacing token, hence the raw [SizedBox].
  Widget _buildBottomSlot(BuildContext context) {
    return Obx(() {
      if (controller.editingWalletId.value == null) {
        return SizedBox(height: MediaQuery.of(context).padding.bottom);
      }

      return SafeArea(
        top: false,
        child: MoneyKeypadPanel(
          onKeyPress: controller.updateAmount,
          onDelete: controller.deleteChar,
          onClear: controller.clearAmount,
          suggestions: const [
            100000,
            200000,
            500000,
            1000000,
            2000000,
            5000000,
          ],
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
