import 'package:flutter/material.dart';

import '../../core/config/tokens/cc_base_colors.dart';
import '../../core/extensions/cc_context_extension.dart';

class FadeInImageWidget extends StatelessWidget {
  const FadeInImageWidget({
    Key? key,
    required this.image,
    this.placeholder,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  }) : super(key: key);

  final ImageProvider image;
  final Widget? placeholder;
  final BoxFit fit;
  final double? width, height;

  @override
  Widget build(BuildContext context) => FadeInImage(
    placeholder: image,
    image: image,
    fit: fit,
    width: width,
    height: height,
    imageErrorBuilder: (context, error, stackTrace) =>
        placeholder ??
        Container(
          color: CcBaseColors.neutral5,
          child: Icon(Icons.image_not_supported, color: context.ccColorScheme.onSurfaceVariant),
        ),
  );
}
