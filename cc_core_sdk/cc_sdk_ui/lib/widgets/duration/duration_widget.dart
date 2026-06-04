import 'package:flutter/material.dart';

import '../../core/extensions/cc_context_extension.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';
import '../text/cc_text.dart';

class DurationWidget extends StatelessWidget {
  const DurationWidget({Key? key, required this.duration}) : super(key: key);

  final String duration;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: context.respPadding(8.0),
      vertical: context.respPadding(4.0),
    ),
    decoration: BoxDecoration(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(4),
    ),
    child: CcText(
      duration,
      fontSize: context.respFontSize(12.0),
      color: context.ccColorScheme.onPrimary,
    ),
  );
}
