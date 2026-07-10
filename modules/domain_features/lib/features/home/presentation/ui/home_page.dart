import 'package:auto_route/annotations.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../get_x/home_controller.dart';
import 'widgets/finance_app_bar.dart';

@RoutePage()
class HomePage extends CcGetView<HomeController> {
  const HomePage({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return const FinanceAppBar();
  }

  @override
  Widget? buildContent(BuildContext context) {
    return const CcGradientCardLayout(child: CcText('Home Page'));
  }
}
