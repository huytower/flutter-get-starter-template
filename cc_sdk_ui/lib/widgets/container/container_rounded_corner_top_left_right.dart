import 'package:flutter/material.dart';

import '../../core/extensions/cc_context_extension.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';
import '../../core/helper/cc_widget_helper.dart';

class ContainerRoundedCornerTopLeftRight extends StatelessWidget {
  const ContainerRoundedCornerTopLeftRight({super.key});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.ccColorScheme.surface,
      borderRadius: CcWidgetHelper.getBorderRoundedSquareTopLeftRight(),
    ),
    width: MediaQuery.sizeOf(context).width,
    height: context.respPadding(4.0),
  );
}
