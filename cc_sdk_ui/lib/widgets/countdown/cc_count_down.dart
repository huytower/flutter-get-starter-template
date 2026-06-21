import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/config/tokens/cc_base_colors.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';
import '../text/cc_text.dart';

class CcCountDown extends StatefulWidget {
  const CcCountDown({
    Key? key,
    required this.seconds,
    this.onTimerFinish,
    this.style,
  }) : super(key: key);

  final int seconds;
  final VoidCallback? onTimerFinish;
  final TextStyle? style;

  @override
  _CcCountDownState createState() => _CcCountDownState();
}

class _CcCountDownState extends State<CcCountDown> {
  late Timer _timer;
  int _start = 0;

  @override
  void initState() {
    super.initState();
    _start = widget.seconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          widget.onTimerFinish?.call();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CcText(
    '$_start',
    textStyle:
        widget.style ??
        TextStyle(
          fontSize: context.respFontSize(16.0),
          fontWeight: FontWeight.bold,
          color: CcBaseColors.neutral100,
        ),
  );
}
