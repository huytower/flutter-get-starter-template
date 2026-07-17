import 'package:flutter/material.dart';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';

class ProfileMenuGroup extends StatelessWidget {
  final List<Widget> items;

  const ProfileMenuGroup({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      rows.add(items[i]);
      if (i < items.length - 1) {
        rows.add(const CcDividerHorizontalLine());
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: context.ccColorScheme.surface,
        borderRadius: BorderRadius.circular(
          context.respDim(CcCircularParams.CARD),
        ),
        border: Border.all(
          color: context.ccColorScheme.outlineVariant.withAlpha(10),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }
}
