import 'package:cc_sdk/core/helper/cc_string_helper.dart';
import 'package:flutter/material.dart';

import '../../core/extensions/common/cc_responsive_extension.dart';
import '../flex/cc_flex.dart';
import '../inkwell/cc_inkwell.dart';
import '../space/cc_space.dart';

@immutable
class IconCopy extends StatelessWidget {
  const IconCopy({Key? key, this.height, this.color}) : super(key: key);

  final double? height;
  final Color? color;

  @override
  Center build(BuildContext context) => Center(
    child: SizedBox.square(
      dimension: height ?? 25,
      child: Icon(
        Icons.copy,
        color: color ?? Colors.grey,
        size: context.respIconSize(baseSize: 15.0),
      ),
    ),
  );
}

@immutable
class CcCopyBtn extends StatelessWidget {
  const CcCopyBtn({super.key, this.onTap, this.title, this.size = 25.0});

  final VoidCallback? onTap;
  final String? title;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Stack(
      children: [
        IconCopy(height: size),
        CcInkWell(
          onTap: onTap ?? () => CcStringHelper.copyToClipboard(title ?? ''),
        ),
      ],
    ),
  );
}

@immutable
class CcCopyWidget extends StatelessWidget {
  const CcCopyWidget({super.key, required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) => CcRowBetween(
    children: [
      const CcSpaceXS(),

      Expanded(flex: 9, child: child),

      /// section : copy widget
      Expanded(flex: 1, child: CcCopyBtn(title: title)),

      const CcSpaceXS(),
    ],
  );
}
