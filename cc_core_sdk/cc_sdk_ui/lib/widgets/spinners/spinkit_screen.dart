import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../core/config/tokens/cc_base_colors.dart';
import '../../core/extensions/cc_context_extension.dart';

class SpinkitScreen extends StatelessWidget {
  const SpinkitScreen({Key? key, this.color}) : super(key: key);

  final Color? color;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.ccColorScheme.surface,
    body: Center(
      child: SpinKitDoubleBounce(
        color: color ?? context.ccColorScheme.primary,
        size: 50.0,
      ),
    ),
  );
}
