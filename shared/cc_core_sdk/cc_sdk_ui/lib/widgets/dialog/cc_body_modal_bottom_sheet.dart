import 'package:flutter/cupertino.dart';

class CcBodyModalBottomSheet extends StatelessWidget {
  final Widget? w;

  const CcBodyModalBottomSheet({Key? key, this.w}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Container(child: w));
  }
}
