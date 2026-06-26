import 'package:flutter/material.dart';

import '../../core/extensions/common/cc_responsive_extension.dart';

class SectionDesWidget extends StatelessWidget {
  const SectionDesWidget({Key? key, required this.des}) : super(key: key);

  final String des;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(),
    child: SizedBox(
      width: double.infinity,
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.grey,
            fontSize: context.respFontSize(15.0),
            fontWeight: FontWeight.w400,
          ),
          text: des,
        ),
        maxLines: 1,
        textAlign: TextAlign.start,
      ),
    ),
  );
}
