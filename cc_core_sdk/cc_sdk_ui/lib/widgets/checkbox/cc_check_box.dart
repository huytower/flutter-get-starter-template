import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../core/config/tokens/cc_circular_params.dart';

class CcCheckBox extends StatelessWidget {
  const CcCheckBox({Key? key, required this.isChecked, required this.onChanged})
    : super(key: key);

  final bool isChecked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onChanged(!isChecked),
    child: Container(
      width: context.respIconSize(baseSize: 24.0),
      height: context.respIconSize(baseSize: 24.0),
      decoration: BoxDecoration(
        color: isChecked ? context.ccColorScheme.primary : Colors.transparent,
        border: Border.all(
          color: isChecked ? context.ccColorScheme.primary : Colors.grey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(CcCircularParams.RADIUS_XS),
      ),
      child: isChecked
          ? Icon(
              Icons.check,
              size: context.respIconSize(baseSize: 16.0),
              color: Colors.white,
            )
          : null,
    ),
  );
}
