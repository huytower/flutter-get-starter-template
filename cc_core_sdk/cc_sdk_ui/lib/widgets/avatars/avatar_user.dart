import 'package:flutter/material.dart';

import '../../core/helper/cc_widget_helper.dart';
import '../container/cc_containers.dart';

class AvatarUser extends StatelessWidget {
  final String? imageUrl;
  final String? pathDefault;
  final double width;
  final VoidCallback? onError;

  const AvatarUser({
    super.key,
    this.imageUrl,
    this.pathDefault,
    this.width = 50,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null && pathDefault == null) {
      return const SizedBox();
    }

    return CcContainerCircle(
      bgColor: Colors.transparent,
      strokeColor: Colors.transparent,
      strokeWidth: 2,
      child: ClipOval(
        child: Container(
          height: width,
          width: width,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: CcWidgetHelper.getCircleBorderRadius(),
          ),
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: width,
        height: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          onError?.call();
          return _buildDefaultImage();
        },
      );
    }
    return _buildDefaultImage();
  }

  Widget _buildDefaultImage() {
    if (pathDefault != null && pathDefault!.isNotEmpty) {
      return Image.asset(
        pathDefault!,
        width: width,
        height: width,
        fit: BoxFit.cover,
      );
    }
    return Icon(Icons.person, size: width * 0.6);
  }
}
