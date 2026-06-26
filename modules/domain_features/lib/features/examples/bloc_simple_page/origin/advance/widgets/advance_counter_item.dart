import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../advance_bloc.dart';
import '../advance_bloc_event.dart';

/// Counter item widget for advance bloc page
class AdvanceCounterItem extends StatelessWidget {
  final AdvanceBloc bloc;

  const AdvanceCounterItem({super.key, required this.bloc});

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
            'CloseButtonWidget() :'.Log();
            bloc.add(IncreaseEvent());
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
