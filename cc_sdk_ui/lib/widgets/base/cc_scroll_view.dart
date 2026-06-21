import 'package:flutter/cupertino.dart';

class CcScrollView extends StatelessWidget {
  const CcScrollView({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) => getContainerWidget();

  Widget getContainerWidget() => CustomScrollView(
    slivers: [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Column(children: [child]),
      ),
    ],
  );
}
