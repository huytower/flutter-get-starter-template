import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class TriggerSwitch extends StatefulWidget {
  const TriggerSwitch({
    Key? key,
    required this.v,
    required this.on,
    required this.off,
  }) : super(key: key);

  final RxInt v;

  final VoidCallback on, off;

  @override
  State<TriggerSwitch> createState() => _TriggerSwitchState();
}

class _TriggerSwitchState extends State<TriggerSwitch> {
  @override
  Widget build(BuildContext context) => AnimatedToggleSwitch<int>.rolling(
    current: widget.v.value,
    values: const [0, 1],
    onChanged: (i) => setState(() {
      /// update UI
      widget.v.value = i;

      /// call trigger methods
      i == 1 ? widget.off() : widget.on();
    }),
  );

  Widget rollingIconBuilder(int value, Size iconSize, bool foreground) {
    IconData data = Icons.vpn_key_off;
    if (value.isEven) data = Icons.vpn_lock;
    return Icon(data, size: iconSize.shortestSide);
  }
}
