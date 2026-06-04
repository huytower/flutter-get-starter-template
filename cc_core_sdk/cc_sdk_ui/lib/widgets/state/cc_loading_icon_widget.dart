import 'package:flutter/cupertino.dart';

import '../../core/config/tokens/cc_base_colors.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';
import '../../core/helper/cc_widget_helper.dart';

// Purpose:
// small reusable widgets for loading states and empty API responses
// intended as part of the shared UI library
class CcLoadingIconWidget extends StatelessWidget {
  const CcLoadingIconWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      height: context.respIconSize(baseSize: 60.0),
      width: context.respIconSize(baseSize: 60.0),
      decoration: BoxDecoration(
        color: CcBaseColors.neutral40,
        borderRadius: CcWidgetHelper.getBorderRoundedSM(),
      ),
      child: getLoadingWidget(context),
    ),
  );

  Widget getLoadingWidget(BuildContext context) => CupertinoActivityIndicator(
    color: CcBaseColors.white100,
    radius: context.respIconSize(baseSize: 15.0) / 2,
  );
}
