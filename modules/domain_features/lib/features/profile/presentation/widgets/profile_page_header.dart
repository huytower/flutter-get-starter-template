import 'dart:math';

import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:flutter/material.dart';

import '../../../user_level/domain/entities/user_level_status_entity.dart';
import 'profile_experience_card.dart';
import 'profile_info_card.dart';

class ProfilePageHeader extends StatefulWidget {
  final CcUserEntity? user;
  final String displayName;
  final int level;
  final int daysToNextAudit;
  final UserLevelStatusEntity levelStatus;
  final bool initialFlipped;
  final Function(bool isFlipped)? onFlip;
  final VoidCallback? onEditName;
  final VoidCallback? onLinkAccount;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onLinkPhone;

  const ProfilePageHeader({
    super.key,
    required this.user,
    required this.displayName,
    required this.level,
    required this.daysToNextAudit,
    required this.levelStatus,
    this.initialFlipped = false,
    this.onFlip,
    this.onEditName,
    this.onLinkAccount,
    this.onAvatarTap,
    this.onLinkPhone,
  });

  @override
  State<ProfilePageHeader> createState() => _ProfilePageHeaderState();
}

class _ProfilePageHeaderState extends State<ProfilePageHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late bool _isFrontVisible;

  @override
  void initState() {
    super.initState();
    _isFrontVisible = !widget.initialFlipped;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
      value: widget.initialFlipped ? 1.0 : 0.0,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_controller.isAnimating) return;

    if (_isFrontVisible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFrontVisible = !_isFrontVisible;
    });
    widget.onFlip?.call(!_isFrontVisible);
  }

  @override
  Widget build(BuildContext context) {
    // Fixed height to ensure both surfaces are identical
    final cardHeight = context.respDim(150);

    return CcSymmetricPadding(
      horizontal: CcPaddingParams.PAGE_SM,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isUnder = angle > pi / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isUnder
                ? Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: cardHeight,
                      child: ProfileExperienceCard(
                        level: widget.level,
                        levelStatus: widget.levelStatus,
                        onTap: _toggleCard,
                      ),
                    ),
                  )
                : SizedBox(
                    height: cardHeight,
                    child: ProfileInfoCard(
                      user: widget.user,
                      level: widget.level,
                      daysToNextAudit: widget.daysToNextAudit,
                      levelStatus: widget.levelStatus,
                      onTap: _toggleCard,
                      onEditName: widget.onEditName,
                      onLinkAccount: widget.onLinkAccount,
                      onAvatarTap: widget.onAvatarTap,
                      onLinkPhone: widget.onLinkPhone,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
