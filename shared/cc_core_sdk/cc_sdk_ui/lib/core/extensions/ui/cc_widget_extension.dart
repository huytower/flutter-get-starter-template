import 'package:flutter/material.dart';

extension CcWidgetExtension on Widget {
  Widget visibleWhen(bool condition()) {
    return Visibility(visible: condition(), child: this);
  }
}
