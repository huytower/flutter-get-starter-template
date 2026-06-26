import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../simple_cubit_interface.dart';

/// Counter item widget with increment functionality
class SimpleCounterItem extends StatelessWidget {
  final SimpleCubitInterface cubit;

  const SimpleCounterItem({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return CcCard(
      height: 100,
      width: double.infinity,
      backgroundColor: context.ccColorScheme.surfaceContainerHighest,
      hasShadow: false,
      child: CcInteractBtnWrapper(
        onTap: () {
          'DebounceWidget'.Log();
        },
        useDebounce: true,
        isBouncing: true,
        child: CcCloseBtn(
          onTap: () {
            'cubit : close() :'.Log();
            cubit.increase();
          },
          icon: Icon(
            Icons.access_alarm,
            color: context.ccColorScheme.onSurface,
            size: context.respIconSize(baseSize: 80.0),
          ),
          width: 120,
          bgColor: context.ccColorScheme.primary,
        ),
      ),
    );
  }
}
