import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class CounterActionButton extends StatelessWidget {
  const CounterActionButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.color,
  });

  final VoidCallback onTap;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CcInteractBtnWrapper(
      onTap: onTap,
      useDebounce: true,
      isBouncing: true,
      child: CcCloseBtn(
        onTap: onTap,
        icon: Icon(
          icon,
          color: color,
          size: context.respIconSize(baseSize: 48.0),
        ),
        width: 120,
        bgColor: color.withOpacity(0.1),
      ),
    );
  }
}
