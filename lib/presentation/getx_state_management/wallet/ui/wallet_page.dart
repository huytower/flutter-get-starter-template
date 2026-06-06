import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_flutter_template/presentation/getx_state_management/wallet/get_x/wallet_controller.dart';

import 'widgets/wallet_header.dart';
import 'widgets/wallet_list_item.dart';
import 'widgets/wallet_section_header.dart';

@RoutePage()
class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(
      init: WalletController(),
      builder: (controller) {
        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const WalletHeader(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.respPadding(
                          CcPaddingParams.PAGE_XS,
                        ),
                      ),
                      child: Column(
                        children: [
                          const CcSpaceMD(),
                          WalletSectionHeader(
                            title: el.tr(CcLocaleKeys.home_my_wallets),
                            count: 2,
                          ),
                          const CcSpaceXS(),
                          WalletListItem(
                            icon: Icons.account_balance_outlined,
                            title: 'acb 790',
                            balance: '2.000.000 đ',
                            onTap: () {},
                          ),
                          WalletListItem(
                            icon: Icons.attach_money_outlined,
                            title: 'Cash',
                            balance: '-340.301 đ',
                            isNegative: true,
                            onTap: () {},
                          ),
                          const CcSpaceLG(),
                          WalletSectionHeader(
                            title: el.tr(CcLocaleKeys.home_recent_activity),
                            isAction: true,
                          ),
                          const CcSpaceXS(),
                          WalletListItem(
                            icon: Icons.savings_outlined,
                            title: el.tr(CcLocaleKeys.app_name),
                            subtitle: el.tr(CcLocaleKeys.app_loading),
                            onTap: () {},
                          ),
                          const CcSpaceLG(),
                          WalletSectionHeader(
                            title: el.tr(CcLocaleKeys.home_view_all),
                            isAction: true,
                          ),
                          const CcSpaceXS(),
                          // Add more items as needed
                          SizedBox(
                            height: context.respDim(120),
                          ), // Space for bottom bar
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
