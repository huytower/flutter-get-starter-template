import 'package:flutter/material.dart';

import '../../core/extensions/cc_context_extension.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';
import '../../core/helper/cc_widget_helper.dart';
import '../text/cc_text.dart';

class CcDebounce extends StatefulWidget {
  const CcDebounce({
    super.key,
    required this.onTap,
    this.child,
    this.duration = const Duration(milliseconds: 500),
    this.title,
    this.bgColor,
    this.textColor,
    this.icon,
    this.iconColor,
    this.isEnable = true,
    this.allowShowLoading = true,
  });

  final VoidCallback? onTap;
  final Widget? child;
  final Duration duration;
  final String? title;
  final List<Color>? bgColor;
  final Color? textColor, iconColor;
  final IconData? icon;
  final bool isEnable;
  final bool allowShowLoading;

  @override
  _CcDebounceState createState() => _CcDebounceState();
}

class _CcDebounceState extends State<CcDebounce> {
  bool _isDebouncing = false;

  @override
  Widget build(BuildContext context) {
    if (widget.child != null) {
      return SizedBox(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.isEnable && !_isDebouncing
              ? () {
                  setState(() => _isDebouncing = true);
                  widget.onTap?.call();
                  Future.delayed(
                    widget.duration,
                    () => setState(() => _isDebouncing = false),
                  );
                }
              : null,
          child: widget.child,
        ),
      );
    }

    return GestureDetector(
      onTap: widget.isEnable && !_isDebouncing
          ? () {
              setState(() => _isDebouncing = true);
              widget.onTap?.call();
              Future.delayed(
                widget.duration,
                () => setState(() => _isDebouncing = false),
              );
            }
          : null,
      child: Container(
        height: context.respIconSize(baseSize: 48.0),
        decoration: BoxDecoration(
          borderRadius: CcWidgetHelper.getBorderRoundedSM(),
          gradient: LinearGradient(
            colors:
                widget.bgColor ??
                [context.ccColorScheme.primary, context.ccColorScheme.primary],
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: context.respIconSize(baseSize: 15.0),
                  color: widget.iconColor ?? context.ccColorScheme.onPrimary,
                ),
                const SizedBox(width: 8),
              ],
              CcText(
                widget.title ?? '',
                color: widget.isEnable
                    ? widget.textColor
                    : context.ccColorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
