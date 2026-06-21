import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FadeWidget extends StatelessWidget {
  const FadeWidget({Key? key, required this.child, this.visible = true})
    : super(key: key);

  final bool visible;

  final Widget child;

  @override
  AnimatedOpacity build(c) => AnimatedOpacity(
    duration: const Duration(milliseconds: 500),
    opacity: visible ? 1.0 : 0.0,
    child: visible ? child : const SizedBox(),
  );
}
