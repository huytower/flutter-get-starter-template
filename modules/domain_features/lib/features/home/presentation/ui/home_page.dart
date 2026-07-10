import 'package:auto_route/annotations.dart';
import 'package:domain_features/export_domain_features.dart';
import 'package:flutter/material.dart';

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
    return const TransactionPage();
  }
}
