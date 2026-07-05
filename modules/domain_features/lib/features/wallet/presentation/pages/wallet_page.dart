import 'package:auto_route/auto_route.dart';
import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../../core/util/icon_utils.dart';
import '../../domain/entities/wallet_entity.dart';
import '../controller/wallet_controller.dart';
import '../widgets/add_wallet_sheet.dart';
import '../widgets/shimmer_wallet_card.dart';
import '../widgets/wallet_header.dart';
import '../widgets/wallet_list_item.dart';

@RoutePage()
class WalletPage extends CcGetView<WalletController> with CcPullRefreshMixin {
  const WalletPage({super.key});

  @override
  bool get enableAppBar => true;

  @override
  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      title: Builder(
        builder: (context) => CcText(
          el.tr(CcLocaleKeys.wallet_my_account),
          textStyle: context.ccTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Get.context?.ccColorScheme.primary,
      elevation: 0,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Thêm ví',
            onPressed: () => _openAddWallet(context),
          ),
        ),
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
                case WalletDeleteOutcome.notEmpty:
                  CcSnackBarHelper.showErrorSnackBar(
                    context: context,
                    message: 'Không thể xóa: số dư của ví phải bằng 0',
                  );
                case WalletDeleteOutcome.error:
                  CcSnackBarHelper.showErrorSnackBar(
                    context: context,
                    message: controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : 'Xóa ví thất bại',
                  );
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget? buildContent() {
    final isLoading =
        controller.layoutStatus.value == CcLayoutStatus.loading;

    return FadePageWrapper(
      child: Builder(
        builder: (context) => buildPullToRefresh(
          context: context,
          onRefresh: controller.loadWallets,
          child: Builder(
            builder: (context) {
              return Obx(
                () => Column(
                children: [
                  const WalletHeader(),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(
                        context.respPadding(CcPaddingParams.SPACE_MD),
                      ),
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.ccColorScheme.surface,
                            borderRadius: BorderRadius.circular(context.respDim(20)),
                            boxShadow: [
                              BoxShadow(
                                color: context.ccColorScheme.onSurface.withOpacity(0.05),
                                blurRadius: context.respDim(10),
                                offset: Offset(0, context.respDim(4)),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildSectionCard(
                                context,
                                title:
                                    '${el.tr(CcLocaleKeys.wallet_spending_account)} (${controller.wallets.length})',
                                onTap: () {},
                              ),
                              if (isLoading)
                                ...List.generate(
                                  3,
                                  (index) => const ShimmerWalletCard(),
                                )
                              else
                                ...controller.wallets.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final wallet = entry.value;
                                  return Column(
                                    children: [
                                      WalletListItem(
                                        icon: iconDataFromCode(wallet.iconCode),
                                        title: wallet.name,
                                        balance: controller.isBalanceVisible.value
                                            ? '${controller.bookBalanceOf(wallet.id).toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")} đ'
                                            : '*********',
                                        onTap: () {
                                          getIt<WalletCoordinator>()
                                              .navigateToWalletDetail(
                                            context,
                                            wallet,
                                          );
                                        },
                                        onMore: () =>
                                            _openWalletActions(context, wallet),
                                      ),
                                      if (index < controller.wallets.length - 1)
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: context.respPadding(
                                              CcPaddingParams.SPACE_LG,
                                            ),
                                          ),
                                          child: Divider(
                                            height: context.respDim(1),
                                            color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.2),
                                          ),
                                        ),
                                    ],
                                  );
                                }),
                              SizedBox(height: context.respDim(8)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_LG)),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CcText(
              title,
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.ccColorScheme.onSurface,
              ),
            ),
            Icon(Icons.chevron_right, color: context.ccColorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
