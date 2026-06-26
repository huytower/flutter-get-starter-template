import 'package:cc_sdk_ui/widgets/container/cc_gradient_card_layout.dart';
import 'package:domain_features/features/comment/presentation/get_x/comment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:mobile_flutter_template/presentation/getx_state_management/wallet/ui/wallet_page.dart';

class NotificationTabContent extends StatefulWidget {
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
    return const CcGradientCardLayout(child: WalletPage());
  }
}
