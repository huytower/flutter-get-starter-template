import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// A full-bleed pink "Congratulations!" banner with a wiggling gift icon,
/// bold headline, and a close button — recreated to match the reference
/// composition (flat pink background + floating white card).
///
/// Usage:
/// ```dart
/// Scaffold(
///   body: CcRewardCompletionBanner(
///     message: 'Congratulations ! You have successfully\n'
///         'Completed the 100 Days UI Challenge',
///     onClose: () {},
///   ),
/// )
/// ```
class CcRewardCompletionBanner extends StatefulWidget {
  const CcRewardCompletionBanner({
    super.key,
    this.message =
        'Congratulations ! You have successfully\nCompleted the 100 Days UI Challenge',
    this.backgroundColor,
    this.onClose,
  });

  final String message;
  final Color? backgroundColor;
  final VoidCallback? onClose;

  @override
  State<CcRewardCompletionBanner> createState() =>
      _CcRewardCompletionBannerState();
}

class _CcRewardCompletionBannerState extends State<CcRewardCompletionBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wiggleController;
  late final Animation<double> _wiggle;

  @override
  void initState() {
    super.initState();
    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _wiggle = Tween<double>(begin: -0.06, end: 0.06).animate(
      CurvedAnimation(parent: _wiggleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        color: widget.backgroundColor ?? CcBaseColors.brand500,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            context.respPadding(CcPaddingParams.PAGE_SM),
            context.respPadding(CcPaddingParams.PAGE_SM),
            context.respPadding(CcPaddingParams.PAGE_XL),
            context.respPadding(CcPaddingParams.PAGE_SM),
          ),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(context.respDim(20)),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withOpacity(0.15),
                blurRadius: context.respDim(18),
                offset: Offset(0, context.respDim(8)),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _wiggle,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _wiggle.value,
                        child: child,
                      );
                    },
                    child: Text(
                      '🎁',
                      style: TextStyle(fontSize: context.respFontSize(48)),
                    ),
                  ),
                  SizedBox(width: context.respDim(12)),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: context.ccTextTheme.titleLarge?.copyWith(
                        fontWeight: CcTypographyParams.bold,
                        color: scheme.onSurface,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: -context.respDim(8),
                right: -context.respDim(32),
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Padding(
                    padding: EdgeInsets.all(context.respDim(8)),
                    child: Icon(
                      Icons.close,
                      size: context.respIconSize(baseSize: 20),
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
