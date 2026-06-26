import 'package:flutter/material.dart';

/// load Background thumbnail ui from server api
class BackgroundImageWidget extends StatelessWidget {
  const BackgroundImageWidget({Key? key, @required this.thumbnail})
    : super(key: key);

  final String? thumbnail;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.transparent,
      image: DecorationImage(
        image: NetworkImage(thumbnail!),
        fit: BoxFit.fitHeight,
      ),
    ),
  );
}
