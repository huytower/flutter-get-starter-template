import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/util/gradient_app_bar.dart';
import '../../../../core/util/icon_utils.dart';
import '../../../budget_allocation/presentation/widgets/add_wallet_sheet.dart';
import '../../domain/entities/wallet_entity.dart';
import '../get_x/wallet_controller.dart';

@RoutePage()
class WalletListPage extends CcGetView<WalletController> {
  const WalletListPage({super.key});

  @override
  bool get enableAppBar => true;

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
      title: Center(
        child: CcText(
          el.tr(CcLocaleKeys.wallet_your_wallets),
          textStyle: context.ccTextTheme.titleMedium?.copyWith(
            color: context.ccColorScheme.onPrimary,
            fontWeight: CcTypographyParams.bold,
          ),
        ),
      ),
      actions: [
        CcIconButton.bouncing(
          icon: Icon(
            Icons.add,
            color: context.ccColorScheme.onPrimary,
            size: context.respIconSize(baseSize: 24),
          ),
          tooltip: el.tr(CcLocaleKeys.wallet_add_title),
          onTap: () => _openForm(context),
        ),
        Obx(
          () => CcIconButton.bouncing(
            onTap: controller.toggleEditMode,
            tooltip: controller.isEditMode.value
                ? el.tr(CcLocaleKeys.common_done)
                : el.tr(CcLocaleKeys.common_edit),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                controller.isEditMode.value
                    ? Icons.check_circle_outline_rounded
                    : Icons.tune_rounded,
                key: ValueKey(controller.isEditMode.value),
                color: context.ccColorScheme.onPrimary,
                size: context.respIconSize(baseSize: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openForm(BuildContext context, {WalletEntity? wallet}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddWalletSheet(wallet: wallet),
    );
  }

  void _confirmDelete(BuildContext context, WalletEntity wallet) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final scheme = sheetContext.ccColorScheme;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(
              sheetContext.respPadding(CcPaddingParams.SPACE_LG),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.all(sheetContext.respDim(14)),
                    decoration: BoxDecoration(
                      color: scheme.error.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: scheme.error,
                      size: sheetContext.respIconSize(baseSize: 28),
                    ),
                  ),
                ),
                const CcSpaceMD(),
                CcText(
                  el.tr(CcLocaleKeys.wallet_delete_title),
                  align: Alignment.center,
                  textAlign: TextAlign.center,
                  textStyle: sheetContext.ccTextTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const CcSpaceSM(),
                CcText(
                  el.tr(CcLocaleKeys.wallet_delete_confirm_msg),
                  align: Alignment.center,
                  maxLines: 5,
                  textAlign: TextAlign.center,
                  textStyle: sheetContext.ccTextTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const CcSpaceLG(),
                Row(
                  children: [
                    Expanded(
                      child: CcBaseBtn(
                        title: el.tr(CcLocaleKeys.common_cancel),
                        bgColor: [
                          scheme.surfaceContainerHighest,
                          scheme.surfaceContainerHighest,
                        ],
                        textColor: scheme.onSurface,
                        onTap: () => Navigator.of(sheetContext).pop(),
                      ),
                    ),
                    SizedBox(width: sheetContext.respDim(12)),
                    Expanded(
                      child: CcBaseBtn(
                        title: el.tr(CcLocaleKeys.common_delete),
                        bgColor: [scheme.error, scheme.error],
                        textColor: scheme.onError,
                        onTap: () async {
                          Navigator.of(sheetContext).pop();
                          final outcome = await controller.deleteWallet(
                            wallet.id,
                          );
                          if (!context.mounted) return;
                          _handleDeleteOutcome(context, outcome);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleDeleteOutcome(BuildContext context, WalletDeleteOutcome outcome) {
    switch (outcome) {
      case WalletDeleteOutcome.success:
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(CcLocaleKeys.common_done),
        );
        break;
      case WalletDeleteOutcome.notEmpty:
        CcSnackBarHelper.showErrorSnackBar(
          context: context,
          message: el.tr(CcLocaleKeys.wallet_delete_error_not_empty),
        );
        break;
      case WalletDeleteOutcome.protected:
        CcSnackBarHelper.showErrorSnackBar(
          context: context,
          message: el.tr(CcLocaleKeys.wallet_delete_error_protected),
        );
        break;
      case WalletDeleteOutcome.error:
        CcSnackBarHelper.showErrorSnackBar(
          context: context,
          message: controller.errorMessage.value.isNotEmpty
              ? controller.errorMessage.value
              : el.tr(CcLocaleKeys.app_error_general),
        );
        break;
    }
  }

  @override
  Widget? buildContent(BuildContext context) {
    return Builder(
      builder: (context) => Obx(() {
        if (controller.wallets.isEmpty) {
          return Center(
            child: CcText(
              el.tr(CcLocaleKeys.wallet_empty),
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                color: context.ccColorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        final isEdit = controller.isEditMode.value;
        return ListView(
          padding: EdgeInsets.all(
            context.respPadding(CcPaddingParams.SPACE_MD),
          ),
          children: controller.wallets
              .map(
                (wallet) => _WalletListCard(
                  wallet: wallet,
                  isEditMode: isEdit,
                  canDelete: controller.canDeleteWallet(wallet),
                  onEdit: () => _openForm(context, wallet: wallet),
                  onDelete: () => _confirmDelete(context, wallet),
                ),
              )
              .toList(),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Wallet card — edit mode shows iOS-style delete/edit corner badges
// (mirrors BudgetLimitGridCard).
// ---------------------------------------------------------------------------

class _WalletListCard extends StatelessWidget {
  final WalletEntity wallet;
  final bool isEditMode;
  final bool canDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _WalletListCard({
    required this.wallet,
    this.isEditMode = false,
    this.canDelete = true,
    this.onEdit,
    this.onDelete,
  });

  static String _fmt(int value) => value.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final bgColor = Color.alphaBlend(
      scheme.primary.withOpacity(0.10),
      scheme.surface,
    );

    return Container(
      margin: EdgeInsets.only(bottom: context.respDim(12)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Reserve a top band so the corner badges sit fully inside the Stack
          // bounds — a Positioned child painted outside its parent's box does
          // not receive pointer events, which would make the badges untappable.
          Padding(
            padding: EdgeInsets.only(top: context.respDim(10)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.respDim(16)),
              child: _buildCardContent(context, bgColor),
            ),
          ),
          if (isEditMode) ...[
            if (canDelete)
              Positioned(
                top: 0,
                left: 0,
                child: _EditBadge(
                  icon: Icons.remove,
                  color: scheme.error,
                  foregroundColor: scheme.onError,
                  onTap: onDelete,
                ),
              ),
            Positioned(
              top: 0,
              right: 0,
              child: _EditBadge(
                icon: Icons.edit,
                color: scheme.primary,
                foregroundColor: scheme.onPrimary,
                onTap: onEdit,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, Color bgColor) {
    final scheme = context.ccColorScheme;
    final controller = Get.find<WalletController>();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
      color: bgColor,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.respDim(10)),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconDataFromCode(wallet.iconCode),
              size: context.respIconSize(baseSize: 22),
              color: scheme.primary,
            ),
          ),
          SizedBox(width: context.respDim(12)),
          Expanded(
            child: CcText(
              wallet.name,
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Obx(() {
            final balance = controller.bookBalanceOf(wallet.id);
            final visible = controller.isBalanceVisible.value;
            return CcText(
              visible ? '${_fmt(balance)} đ' : '*****',
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: balance >= 0 ? scheme.onSurface : scheme.error,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _EditBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color foregroundColor;
  final VoidCallback? onTap;

  const _EditBadge({
    required this.icon,
    required this.color,
    required this.foregroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: context.respDim(24),
        height: context.respDim(24),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: scheme.surface, width: 1.5),
          boxShadow: [
            BoxShadow(color: scheme.shadow.withOpacity(0.3), blurRadius: 4),
          ],
        ),
        child: Icon(
          icon,
          color: foregroundColor,
          size: context.respIconSize(baseSize: 14),
        ),
      ),
    );
  }
}
