import 'package:flutter/material.dart';

import '../../core/extensions/common/cc_responsive_extension.dart';

// Purpose:
// small reusable widgets for loading states and empty API responses
// intended as part of the shared UI library
class CcProgressIndicator extends StatelessWidget {
  const CcProgressIndicator({Key? key, this.width = 20.0, this.paddingTop})
    : super(key: key);

  final double? paddingTop, width;

  @override
  Padding build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: paddingTop ?? context.respPadding(50.0)),
    child: Center(
      child: SizedBox(
        width: width,
        height: width,
        child: const CircularProgressIndicator(),
      ),
    ),
  );
}
