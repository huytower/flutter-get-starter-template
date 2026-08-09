import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/helper/wallet_icon_helper.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';

/// Lets the user pick a wallet to filter the Report page by.
///
/// Resolves to one of three distinct outcomes (barrier-dismiss and an
/// explicit "clear" both need to end the [Future], but mean different
/// things to the caller):
/// - `null` — dismissed without a choice; caller does nothing.
/// - `''` (empty string) — the "Tất cả các ví" row was tapped; caller
///   clears the filter.
/// - a wallet id — caller sets the filter to that wallet.
class WalletFilterPickerSheet extends StatelessWidget {
  const WalletFilterPickerSheet({
    super.key,
    required this.wallets,
    this.selectedWalletId,
  });

  final List<WalletEntity> wallets;
  final String? selectedWalletId;

  static const List<String> _liquidTypeOrder = [
    WalletType.cash,
    WalletType.bank,
    WalletType.ewallet,
    WalletType.emergencyFund,
  ];

  static Future<String?> show(
    BuildContext context, {
    required List<WalletEntity> wallets,
    String? selectedWalletId,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WalletFilterPickerSheet(
        wallets: wallets,
        selectedWalletId: selectedWalletId,
      ),
    );
  }

  /// Liquid types first (cash → bank → ewallet → emergency fund, matching
  /// [WalletController]'s `_liquidTypeOrder` convention), then investment
  /// positions by name — kept local rather than depending on
  /// `WalletController` for this one ordering rule.
  List<WalletEntity> get _orderedWallets {
    final sorted = [...wallets];
    sorted.sort((a, b) {
      final aIdx = _liquidTypeOrder.indexOf(a.type);
      final bIdx = _liquidTypeOrder.indexOf(b.type);
      if (aIdx == -1 && bIdx == -1) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      if (aIdx == -1) return 1;
      if (bIdx == -1) return -1;
      final typeCompare = aIdx.compareTo(bIdx);
      if (typeCompare != 0) return typeCompare;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_LG)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primary, scheme.primaryContainer],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(context.respDim(16)),
              topRight: Radius.circular(context.respDim(16)),
            ),
          ),
          child: CcText(
            el.tr(CcLocaleKeys.report_filter_by_wallet),
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              color: scheme.onPrimary,
              fontWeight: CcTypographyParams.bold,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(context.respDim(16)),
              bottomRight: Radius.circular(context.respDim(16)),
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(
                vertical: context.respPadding(CcPaddingParams.SPACE_SM),
              ),
              children: [
                _buildRow(
                  context,
                  icon: Icons.apps_rounded,
                  label: el.tr(CcLocaleKeys.report_filter_all_wallets),
                  isSelected: selectedWalletId == null,
                  onTap: () => Navigator.of(context).pop(''),
                ),
                for (final wallet in _orderedWallets)
                  _buildRow(
                    context,
                    icon: iconDataFromCode(wallet.iconCode),
                    label: wallet.name,
                    isSelected: wallet.id == selectedWalletId,
                    onTap: () => Navigator.of(context).pop(wallet.id),
                  ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final scheme = context.ccColorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
          vertical: context.respPadding(CcPaddingParams.SPACE_SM),
        ),
        child: Row(
          children: [
            CcIconToken(
              icon,
              color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
              size: context.respIconSize(baseSize: 20),
            ),
            const CcSpaceMD(),
            Expanded(
              child: CcText(
                label,
                textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                  color: isSelected ? scheme.primary : scheme.onSurface,
                  fontWeight: isSelected
                      ? CcTypographyParams.bold
                      : CcTypographyParams.regular,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                size: context.respIconSize(baseSize: 18),
                color: scheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
