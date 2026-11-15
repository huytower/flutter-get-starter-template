import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter/widgets.dart';

/// Re-applies [CcDeviceHelper.applyOrientationPolicy] whenever the window
/// size changes — e.g. a foldable switching between its cover screen (phone:
/// portrait only) and its inner screen (tablet: free rotation), or split
/// screen resizing the app.
///
/// Must sit above anything that overrides [MediaQuery] (such as
/// `AppContentFrame`) so it sees the real window size.
class OrientationPolicyScope extends StatefulWidget {
  final Widget child;

  const OrientationPolicyScope({super.key, required this.child});

  @override
  State<OrientationPolicyScope> createState() => _OrientationPolicyScopeState();
}

class _OrientationPolicyScopeState extends State<OrientationPolicyScope> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    CcDeviceHelper.applyOrientationPolicy(MediaQuery.sizeOf(context));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
