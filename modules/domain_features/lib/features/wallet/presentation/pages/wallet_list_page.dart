import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
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
    return AppBar(
      title: Builder(
        builder: (context) => CcText(
          el.tr(CcLocaleKeys.wallet_your_wallets),
          textStyle: context.ccTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Get.context?.ccColorScheme.primary,
      elevation: 0,
    );
  }

  @override
  Widget? get floatingActionButton => Builder(
    builder: (context) => CcFloatingActionButton(
      iconData: Icons.add,
      onTap: () => _openForm(context),
    ),
  );

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
        return ListView(
          padding: EdgeInsets.all(
            context.respPadding(CcPaddingParams.SPACE_MD),
          ),
          children: controller.wallets
              .map(
                (wallet) => _WalletListCard(
                  wallet: wallet,
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
// Swipeable wallet card — mirrors BudgetCard.
// ---------------------------------------------------------------------------

class _WalletListCard extends StatefulWidget {
  final WalletEntity wallet;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _WalletListCard({required this.wallet, this.onEdit, this.onDelete});

  static const double _kRevealWidth = 130.0;

  static String _fmt(int value) => value.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );

  @override
  State<_WalletListCard> createState() => _WalletListCardState();
}

class _WalletListCardState extends State<_WalletListCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final delta = -d.delta.dx / _WalletListCard._kRevealWidth;
    _ctrl.value = (_ctrl.value + delta).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    if (velocity < -400 || (_ctrl.value > 0.4 && velocity < 400)) {
      _ctrl.animateTo(1.0, curve: Curves.easeOut);
    } else {
      _ctrl.animateTo(0.0, curve: Curves.easeOut);
    }
  }

  void _close() => _ctrl.animateTo(0.0, curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final bgColor = Color.alphaBlend(
      scheme.primary.withOpacity(0.10),
      scheme.surface,
    );

    return Container(
      margin: EdgeInsets.only(bottom: context.respDim(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.respDim(16)),
        child: GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: Stack(
            children: [
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ActionButton(
                      width: _WalletListCard._kRevealWidth / 2,
                      color: scheme.primary,
                      icon: Icons.edit_outlined,
                      label: el.tr(CcLocaleKeys.common_edit),
                      onTap: () {
                        _close();
                        widget.onEdit?.call();
                      },
                    ),
                    _ActionButton(
                      width: _WalletListCard._kRevealWidth / 2,
                      color: scheme.error,
                      icon: Icons.delete_outline,
                      label: el.tr(CcLocaleKeys.common_delete),
                      onTap: () {
                        _close();
                        widget.onDelete?.call();
                      },
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) => Transform.translate(
                  offset: Offset(
                    -_ctrl.value * _WalletListCard._kRevealWidth,
                    0,
                  ),
                  child: child,
                ),
                child: _buildCardContent(context, bgColor),
              ),
            ],
          ),
        ),
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
              iconDataFromCode(widget.wallet.iconCode),
              size: context.respIconSize(baseSize: 22),
              color: scheme.primary,
            ),
          ),
          SizedBox(width: context.respDim(12)),
          Expanded(
            child: CcText(
              widget.wallet.name,
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Obx(() {
            final balance = controller.bookBalanceOf(widget.wallet.id);
            final visible = controller.isBalanceVisible.value;
            return CcText(
              visible ? '${_WalletListCard._fmt(balance)} đ' : '*****',
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

class _ActionButton extends StatelessWidget {
  final double width;
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.width,
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: context.respIconSize(baseSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.respFontSize(11),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
