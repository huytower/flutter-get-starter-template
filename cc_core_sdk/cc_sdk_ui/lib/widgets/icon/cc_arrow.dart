import 'package:flutter/material.dart';

import '../../core/extensions/common/cc_responsive_extension.dart';

class CcArrowRight extends StatelessWidget {
  const CcArrowRight({Key? key}) : super(key: key);

  @override
  Center build(BuildContext context) => Center(
    child: SizedBox(
      width: 25,
      child: Icon(
        Icons.skip_next,
        color: Colors.black,
        size: context.respIconSize(baseSize: 15.0),
      ),
    ),
  );
}
