import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/data/data_source/color/prj_color.dart';

import '../../../wallet/domain/entities/wallet_entity.dart';
import '../get_x/report_controller.dart';

class ReportFilterPickerSheet extends StatefulWidget {
  const ReportFilterPickerSheet({
    super.key,
    required this.wallets,
    required this.selectedWalletId,
    required this.selectedType,
  });

  final List<WalletEntity> wallets;
  final String? selectedWalletId;
  final ReportFilterType selectedType;

  static Future<({ReportFilterType type, String? walletId})?> show(
    BuildContext context, {
    required List<WalletEntity> wallets,
    required String? selectedWalletId,
    required ReportFilterType selectedType,
  }) {
    return showModalBottomSheet<({ReportFilterType type, String? walletId})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportFilterPickerSheet(
        wallets: wallets,
        selectedWalletId: selectedWalletId,
        selectedType: selectedType,
      ),
    );
  }

  @override
  State<ReportFilterPickerSheet> createState() =>
      _ReportFilterPickerSheetState();
}

class _ReportFilterPickerSheetState extends State<ReportFilterPickerSheet> {
  late ReportFilterType _currentType = widget.selectedType;
  late String? _currentWalletId = widget.selectedWalletId;

  static const List<String> _liquidTypeOrder = [
    WalletType.cash,
    WalletType.bank,
    WalletType.ewallet,
    WalletType.emergencyFund,
  ];

  List<WalletEntity> get _orderedWallets {
    final sorted = [...widget.wallets];
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

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              context.respPadding(CcPaddingParams.SPACE_LG),
            ),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CcText(
                  el.tr(
                    CcLocaleKeys.common_edit,
                  ), // "Lọc" would be better but using existing keys
                  textStyle: context.ccTextTheme.titleMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: CcTypographyParams.bold,
                  ),
                ),
                CcTextButton(
                  text: el.tr(CcLocaleKeys.common_done),
                  onTap: () => Navigator.of(
                    context,
                  ).pop((type: _currentType, walletId: _currentWalletId)),
                ),
              ],
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
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: context.respPadding(CcPaddingParams.SPACE_MD),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      context,
                      el.tr(CcLocaleKeys.report_filter_by_type),
                    ),
                    _buildTypeRow(
                      context,
                      ReportFilterType.all,
                      Icons.apps_rounded,
                      el.tr(CcLocaleKeys.report_filter_all_types),
                    ),
                    _buildTypeRow(
                      context,
                      ReportFilterType.expense,
                      Icons.south_west,
                      el.tr(CcLocaleKeys.common_expense),
                      color: scheme.error,
                    ),
                    _buildTypeRow(
                      context,
                      ReportFilterType.income,
                      Icons.north_east,
                      el.tr(CcLocaleKeys.common_income),
                      color: PrjColors.success,
                    ),
                    _buildTypeRow(
                      context,
                      ReportFilterType.investment,
                      Icons.eco_outlined,
                      el.tr(CcLocaleKeys.transaction_investment),
                      color: scheme.investment,
                    ),
                    _buildTypeRow(
                      context,
                      ReportFilterType.liability,
                      Icons.file_download_outlined,
                      el.tr(CcLocaleKeys.liability_title),
                      color: scheme.liability,
                    ),
                    _buildTypeRow(
                      context,
                      ReportFilterType.lend,
                      Icons.file_upload_outlined,
                      el.tr(CcLocaleKeys.liability_lend),
                      color: scheme.liabilitySecondary,
                    ),

                    const CcSpaceLG(),
                    _buildSectionHeader(
                      context,
                      el.tr(CcLocaleKeys.report_filter_by_wallet),
                    ),
                    _buildWalletRow(
                      context,
                      null,
                      Icons.account_balance_wallet_outlined,
                      el.tr(CcLocaleKeys.report_filter_all_wallets),
                    ),
                    for (final wallet in _orderedWallets)
                      _buildWalletRow(
                        context,
                        wallet.id,
                        iconDataFromCode(wallet.iconCode),
                        wallet.name,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
        vertical: context.respPadding(CcPaddingParams.SPACE_XS),
      ),
      child: CcText(
        title,
        textStyle: context.ccTextTheme.labelMedium?.copyWith(
          color: context.ccColorScheme.primary,
          fontWeight: CcTypographyParams.bold,
        ),
      ),
    );
  }

  Widget _buildTypeRow(
    BuildContext context,
    ReportFilterType type,
    IconData icon,
    String label, {
    Color? color,
  }) {
    final isSelected = _currentType == type;
    final scheme = context.ccColorScheme;

    return CcBouncing(
      onTap: () => setState(() => _currentType = type),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
          vertical: context.respPadding(CcPaddingParams.SPACE_SM),
        ),
        color: isSelected
            ? scheme.primary.withOpacity(0.05)
            : Colors.transparent,
        child: Row(
          children: [
            CcIconToken(
              icon,
              color: isSelected
                  ? scheme.primary
                  : (color ?? scheme.onSurfaceVariant),
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

  Widget _buildWalletRow(
    BuildContext context,
    String? walletId,
    IconData icon,
    String label,
  ) {
    final isSelected = _currentWalletId == walletId;
    final scheme = context.ccColorScheme;

    return CcBouncing(
      onTap: () => setState(() => _currentWalletId = walletId),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
          vertical: context.respPadding(CcPaddingParams.SPACE_SM),
        ),
        color: isSelected
            ? scheme.primary.withOpacity(0.05)
            : Colors.transparent,
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
