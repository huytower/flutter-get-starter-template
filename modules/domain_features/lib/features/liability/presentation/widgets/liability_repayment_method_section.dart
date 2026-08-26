import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/liability_entity.dart';
import '../get_x/liability_base_form_controller.dart';
import 'liability_final_due_date_section.dart';
import 'liability_installment_schedule_section.dart';
import 'liability_pill_toggle.dart';

class LiabilityRepaymentMethodSection extends StatelessWidget {
  final LiabilityBaseFormController controller;
  final Color accentColor;

  const LiabilityRepaymentMethodSection({
    super.key,
    required this.controller,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isBorrowSide = controller.direction == LiabilityDirection.borrow;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CcFormLabel(
                text: isBorrowSide
                    ? el.tr(
                        CcLocaleKeys
                            .transaction_liability_repayment_method_label,
                      )
                    : el.tr(
                        CcLocaleKeys
                            .transaction_liability_collection_method_label,
                      ),
              ),
              const CcSpaceXS(),
              Expanded(
                child: LiabilityPillToggle(
                  selectedIndex:
                      controller.repaymentMethod.value ==
                          LiabilityRepaymentMethod.installment
                      ? 0
                      : 1,
                  firstLabel: isBorrowSide
                      ? el.tr(
                          CcLocaleKeys.transaction_liability_method_installment,
                        )
                      : el.tr(
                          CcLocaleKeys
                              .transaction_liability_method_installment_lend,
                        ),
                  secondLabel: isBorrowSide
                      ? el.tr(
                          CcLocaleKeys.transaction_liability_method_lump_sum,
                        )
                      : el.tr(
                          CcLocaleKeys
                              .transaction_liability_method_lump_sum_lend,
                        ),
                  activeColor: accentColor,
                  onChanged: (index) => controller.setRepaymentMethod(
                    index == 0
                        ? LiabilityRepaymentMethod.installment
                        : LiabilityRepaymentMethod.lumpSum,
                  ),
                ),
              ),
            ],
          ),
          const CcSpaceSM(),
          if (controller.repaymentMethod.value ==
              LiabilityRepaymentMethod.installment)
            LiabilityInstallmentScheduleSection(
              controller: controller,
              accentColor: accentColor,
            )
          else
            LiabilityFinalDueDateSection(
              controller: controller,
              accentColor: accentColor,
            ),
        ],
      );
    });
  }
}
