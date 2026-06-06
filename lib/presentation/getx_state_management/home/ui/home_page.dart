import 'package:auto_route/annotations.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:mobile_flutter_template/presentation/getx_state_management/home/get_x/home_controller.dart';

import '../../base/getx/cc_get_view.dart';
import '../../home/ui/widgets/finance_app_bar.dart';

@RoutePage()
class HomePage extends CcGetView<HomeController> {
  const HomePage({super.key});

  @override
  PreferredSizeWidget? appBar() {
    return const FinanceAppBar();
  }

  @override
  Widget? buildContent() {
    return Builder(
      builder: (context) {
        return FadePageWrapper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildWalletSection(context)],
          ),
        );
      },
    );
  }

  Widget _buildWalletSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.SPACE_MD),
            vertical: context.respPadding(CcPaddingParams.SPACE_SM),
          ),
          child: CcText(
            el.tr(CcLocaleKeys.home_my_wallets),
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: context.respFontSize(CcTypographyParams.titleMedium),
            ),
          ),
        ),
        SizedBox(
          height: context.respDim(180),
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            itemCount: 3, // Mock data
            itemBuilder: (context, index) {
              return _buildWalletCard(context, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCard(BuildContext context, int index) {
    final colors = [
      context.ccColorScheme.primary,
      context.ccColorScheme.secondary,
      context.ccColorScheme.tertiary,
    ];

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.SPACE_XS),
      ),
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
      decoration: BoxDecoration(
        color: colors[index % colors.length],
        borderRadius: BorderRadius.circular(
          context.respDim(CcCircularParams.RADIUS_LG),
        ),
        boxShadow: [
          BoxShadow(
            color: context.ccColorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CcText(
                'Wallet ${index + 1}',
                textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                  color: context.ccColorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.account_balance_wallet_rounded,
                color: context.ccColorScheme.onPrimary.withOpacity(0.8),
                size: context.respIconSize(baseSize: 24),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CcText(
                'Balance',
                textStyle: context.ccTextTheme.labelSmall?.copyWith(
                  color: context.ccColorScheme.onPrimary.withOpacity(0.7),
                ),
              ),
              CcText(
                '\$${(index + 1) * 1250}.00',
                textStyle: context.ccTextTheme.headlineSmall?.copyWith(
                  color: context.ccColorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: context.respFontSize(
                    CcTypographyParams.headlineSmall,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
