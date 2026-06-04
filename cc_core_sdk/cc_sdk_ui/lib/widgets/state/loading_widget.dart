import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/config/tokens/cc_base_colors.dart';
import '../anim/fade_widget.dart';
import 'base_progress_indicator.dart';

// Purpose:
// small reusable widgets for loading states and empty API responses
// intended as part of the shared UI library
/// this ui show loading progress icon for total page
/// - child param. : total widgets in page
class LoadingPageWidget extends StatelessWidget {
  const LoadingPageWidget({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(c) => FadeWidget(
    visible: true,
    child: Stack(
      children: [
        /// Child
        ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [child],
        ),

        /// Background
        Container(
          height: Get.height,
          width: Get.width,
          color: CcBaseColors.neutral70,
        ),

        /// Progress loading icon
        const CcProgressIndicator(),
      ],
    ),
  );
}
