import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:mobile_flutter_template/presentation/getx_state_management/wallet/ui/wallet_page.dart';

import '../../getx_state_management/comment/get_x/comment_controller.dart';

class NotificationTabContent extends StatefulWidget {
  static const String routeName = 'QUICK_TEST';

  const NotificationTabContent({super.key});

  @override
  State<NotificationTabContent> createState() => _NotificationTabContentState();
}

class _NotificationTabContentState extends State<NotificationTabContent> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<CommentController>()) {
      CommentBinding().dependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    // return const DashboardPage();
    return const WalletPage();
  }
}
