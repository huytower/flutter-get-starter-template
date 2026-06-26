import 'package:flutter/material.dart';

import '../../export_cc_sdk_ui.dart';

class AvatarUser extends StatelessWidget {
  final String? imageUrl;
  final String? pathDefault;
  final double width;
  final VoidCallback? onError;
  final VoidCallback? onTap;
  final CcInteractionType interactionType;
  final bool useDebounce;

  // Backward compatibility constructor (defaults to none if no onTap, else bounce)
  const AvatarUser({
    super.key,
    this.imageUrl,
    this.pathDefault,
    this.width = 50,
    this.onError,
    this.onTap,
    this.useDebounce = true,
  }) : interactionType = onTap == null
           ? CcInteractionType.none
           : CcInteractionType.bounce;

  // Private internal constructor
  const AvatarUser._({
    required this.interactionType,
    this.imageUrl,
    this.pathDefault,
    this.width = 50,
    this.onError,
    this.onTap,
    this.useDebounce = true,
    super.key,
  });

  // Named constructors
  factory AvatarUser.bouncing({
    required VoidCallback onTap,
    String? imageUrl,
    String? pathDefault,
    double width = 50,
    VoidCallback? onError,
    bool useDebounce = true,
    Key? key,
  }) => AvatarUser._(
    interactionType: CcInteractionType.bounce,
    onTap: onTap,
    imageUrl: imageUrl,
    pathDefault: pathDefault,
    width: width,
    onError: onError,
    useDebounce: useDebounce,
    key: key,
  );

  factory AvatarUser.simple({
    required VoidCallback onTap,
    String? imageUrl,
    String? pathDefault,
    double width = 50,
    VoidCallback? onError,
    bool useDebounce = true,
    Key? key,
  }) => AvatarUser._(
    interactionType: CcInteractionType.tap,
    onTap: onTap,
    imageUrl: imageUrl,
    pathDefault: pathDefault,
    width: width,
    onError: onError,
    useDebounce: useDebounce,
    key: key,
  );

  factory AvatarUser.static({
    String? imageUrl,
    String? pathDefault,
    double width = 50,
    VoidCallback? onError,
    Key? key,
  }) => AvatarUser._(
    interactionType: CcInteractionType.none,
    imageUrl: imageUrl,
    pathDefault: pathDefault,
    width: width,
    onError: onError,
    useDebounce: false,
    key: key,
  );

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null && pathDefault == null) {
      return const SizedBox();
    }

    final double respWidth = context.respDim(width);

    final baseAvatar = CcContainerCircle(
      bgColor: Colors.transparent,
      strokeColor: Colors.transparent,
      strokeWidth: 2,
      width: respWidth,
      child: ClipOval(
        child: Container(
          height: respWidth,
          width: respWidth,
          decoration: BoxDecoration(
            color: context.ccColorScheme.surfaceVariant,
            borderRadius: CcWidgetHelper.getCircleBorderRadius(),
          ),
          child: _buildImage(respWidth),
        ),
      ),
    );

    // If type is none, return the base avatar directly
    if (interactionType == CcInteractionType.none) {
      return baseAvatar;
    }

    // Otherwise, wrap it in the interaction logic
    return CcInteractBtnWrapper(
      onTap: onTap ?? () {},
      useDebounce: useDebounce,
      isBouncing: interactionType == CcInteractionType.bounce,
      child: baseAvatar,
    );
  }

  Widget _buildImage(double respWidth) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: respWidth,
        height: respWidth,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          onError?.call();
          return _buildDefaultImage(respWidth);
        },
      );
    }
    return _buildDefaultImage(respWidth);
  }

  Widget _buildDefaultImage(double respWidth) {
    if (pathDefault != null && pathDefault!.isNotEmpty) {
      return Image.asset(
        pathDefault!,
        width: respWidth,
        height: respWidth,
        fit: BoxFit.cover,
      );
    }
    return Icon(Icons.person, size: respWidth * 0.6);
  }
}
