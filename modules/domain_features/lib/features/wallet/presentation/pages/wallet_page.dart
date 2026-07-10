import 'package:auto_route/auto_route.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../domain/entities/wallet_entity.dart';
import '../get_x/wallet_controller.dart';
import '../widgets/add_wallet_sheet.dart';
import '../widgets/budget_preview_section.dart';
import '../widgets/shimmer_wallet_card.dart';
import '../widgets/wallet_header.dart';
import '../widgets/wallet_strip.dart';

@RoutePage()
class WalletPage extends CcGetView<WalletController> with CcPullRefreshMixin {
  const WalletPage({super.key});

  @override
  bool get enableAppBar => true;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Builder(
        builder: (context) => CcText(
          el.tr(CcLocaleKeys.nav_wallet),
          textStyle: context.ccTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Get.context?.ccColorScheme.background,
      elevation: 0,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.fact_check_outlined),
            tooltip: 'Đối soát',
            onPressed: () => context.router.push(const ReconcileRoute()),
          ),
        ),
      ],
    );
  }

  void _openAddWallet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddWalletSheet(),
    );
  }

  void _openWalletActions(BuildContext context, WalletEntity wallet) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.edit_outlined,
                color: sheetContext.ccColorScheme.primary,
              ),
              title: const Text('Sửa ví'),
              onTap: () {
                Navigator.pop(sheetContext);
                _editWallet(context, wallet);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: sheetContext.ccColorScheme.error,
              ),
              title: Text(
                'Xóa ví',
                style: TextStyle(color: sheetContext.ccColorScheme.error),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _confirmDelete(context, wallet);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editWallet(BuildContext context, WalletEntity wallet) {
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
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa ví'),
        content: const Text(
          'Chỉ có thể xóa ví khi số dư bằng 0. '
          'Mọi giao dịch của ví sẽ được xóa (soft-delete). Tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final outcome = await controller.deleteWallet(wallet.id);
              if (!context.mounted) return;
              switch (outcome) {
                case WalletDeleteOutcome.success:
                  CcSnackBarHelper.showSuccessSnackBar(
                    context: context,
                    message: 'Đã xóa ví',
                  );
                  break;
                case WalletDeleteOutcome.notEmpty:
                  CcSnackBarHelper.showErrorSnackBar(
                    context: context,
                    message: 'Không thể xóa: số dư của ví phải bằng 0',
                  );
                  break;
                case WalletDeleteOutcome.error:
                  CcSnackBarHelper.showErrorSnackBar(
                    context: context,
                    message: controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : 'Xóa ví thất bại',
                  );
                  break;
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget? buildContent(BuildContext context) {
    return FadePageWrapper(
      child: Builder(
        builder: (context) => buildPullToRefresh(
          context: context,
          onRefresh: controller.loadWallets,
          child: Obx(() {
            final isLoading =
                controller.layoutStatus.value == CcLayoutStatus.loading;
            return ListView(
              children: [
                const WalletHeader(),
                _buildWalletsSection(context, isLoading),
                const BudgetPreviewSection(),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildWalletsSection(BuildContext context, bool isLoading) {
    final scheme = context.ccColorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.respPadding(CcPaddingParams.SPACE_LG),
            context.respPadding(CcPaddingParams.SPACE_LG),
            context.respPadding(CcPaddingParams.SPACE_MD),
            context.respPadding(CcPaddingParams.SPACE_SM),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CcText(
                el.tr(CcLocaleKeys.wallet_your_wallets),
                textStyle: context.ccTextTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onBackground,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _openAddWallet(context),
                    child: Icon(
                      Icons.add_circle_outline_rounded,
                      size: context.respIconSize(baseSize: 20),
                      color: scheme.primary,
                    ),
                  ),
                  SizedBox(width: context.respDim(8)),
                  GestureDetector(
                    onTap: () => context.router.push(const WalletListRoute()),
                    child: CcText(
                      el.tr(CcLocaleKeys.wallet_see_all),
                      textStyle: context.ccTextTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isLoading)
          SizedBox(
            height: context.respDim(110),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
              ),
              itemCount: 3,
              itemBuilder: (_, _i) => Padding(
                padding: EdgeInsets.only(right: context.respDim(10)),
                child: SizedBox(
                  width: context.respDim(110),
                  child: const ShimmerWalletCard(),
                ),
              ),
            ),
          )
        else
          WalletStrip(
            wallets: controller.wallets,
            onMore: (wallet) => _openWalletActions(context, wallet),
          ),
      ],
    );
  }
}
