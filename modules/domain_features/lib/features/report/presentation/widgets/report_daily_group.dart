import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/money_format_helper.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import 'report_daily_list_helpers.dart';
import 'report_transaction_tile.dart';

class DailyGroup extends StatefulWidget {
  const DailyGroup({
    super.key,
    required this.date,
    required this.transactions,
    required this.includeInvestmentAndLiability,
    required this.isEditMode,
  });

  final DateTime date;
  final List<TransactionEntity> transactions;
  final bool includeInvestmentAndLiability;
  final bool isEditMode;

  @override
  State<DailyGroup> createState() => _DailyGroupState();
}

class _DailyGroupState extends State<DailyGroup> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final groupDate = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
    );
    final differenceInDays = today.difference(groupDate).inDays;

    // Recent 15 days: default expanded, otherwise collapsed
    _isExpanded = differenceInDays <= 15;
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletController = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(getIt<WalletController>());

    return Obx(() {
      final currencyCode = walletController.currencyCode.value;
      final totalDaily = computeDailyTotal(
        widget.transactions,
        includeInvestmentAndLiability: widget.includeInvestmentAndLiability,
      );

      final amountText = formatCurrencyWithSymbol(
        totalDaily,
        currencyCode: currencyCode,
      );

      return Container(
        margin: EdgeInsets.only(bottom: context.respDim(16)),
        decoration: BoxDecoration(
          color: context.ccColorScheme.surfaceContainer,
          borderRadius: context.brLg,
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(
                context.respPadding(CcPaddingParams.SPACE_MD),
              ),
              child: Row(
                children: [
                  CcText(
                    el.DateFormat('dd').format(widget.date),
                    textStyle: context.ccTextTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const CcSpaceMD(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Builder(
                            builder: (context) {
                              final weekdayNames = el
                                  .tr(CcLocaleKeys.common_weekday_names)
                                  .split('|');
                              final weekdayIndex = widget.date.weekday - 1;
                              final weekdayText =
                                  (weekdayIndex >= 0 &&
                                      weekdayIndex < weekdayNames.length)
                                  ? weekdayNames[weekdayIndex]
                                  : el.DateFormat(
                                      'EEEE',
                                      context.locale.languageCode,
                                    ).format(widget.date);

                              return CcText(
                                weekdayText,
                                textStyle: context.ccTextTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                          const CcSpaceXS(),
                          CcIconButton.bouncing(
                            icon: Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: context.respIconSize(baseSize: 18),
                              color: context.ccColorScheme.primary,
                            ),
                            onTap: _toggleExpand,
                            width: context.respDim(24),
                            height: context.respDim(24),
                          ),
                        ],
                      ),
                      CcText(
                        el.DateFormat(
                          'MMMM, yyyy',
                          context.locale.languageCode,
                        ).format(widget.date),
                        textStyle: context.ccTextTheme.labelSmall?.copyWith(
                          color: context.ccColorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  CcText(
                    amountText,
                    textStyle: context.ccTextTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: totalDaily >= 0
                          ? PrjColors.success
                          : PrjColors.error,
                    ),
                  ),
                ],
              ),
            ),
            if (_isExpanded) ...[
              CcDividerLine(
                color: context.ccColorScheme.outlineVariant.withValues(
                  alpha: 0.1,
                ),
              ),
              for (final tx in widget.transactions)
                TransactionTile(transaction: tx, isEditMode: widget.isEditMode),
            ],
          ],
        ),
      );
    });
  }
}
