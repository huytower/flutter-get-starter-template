import 'package:flutter/material.dart';

import '../../core/extensions/cc_context_extension.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';

class CcSpeechBubbleIcon extends StatelessWidget {
  const CcSpeechBubbleIcon({super.key, this.size, this.color});

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? context.respIconSize(baseSize: 64);
    final iconColor = color ?? context.ccColorScheme.primary;

    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: CustomPaint(painter: _SpeechBubblePainter(color: iconColor)),
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  _SpeechBubblePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Draw speech bubble shape
    final bubbleSize = size.width * 0.8;
    final bubbleX = (size.width - bubbleSize) / 2;
    final bubbleY = (size.height - bubbleSize) / 2;

    // Main bubble body (rounded rectangle)
    final rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bubbleX, bubbleY, bubbleSize, bubbleSize * 0.7),
      Radius.circular(bubbleSize * 0.2),
    );
    path.addRRect(rRect);

    // Bubble tail at bottom
    final tailWidth = bubbleSize * 0.2;
    final tailHeight = bubbleSize * 0.15;
    final tailX = bubbleX + bubbleSize * 0.4;
    final tailY = bubbleY + bubbleSize * 0.7;

    path.moveTo(tailX, tailY);
    path.lineTo(tailX + tailWidth / 2, tailY + tailHeight);
    path.lineTo(tailX + tailWidth, tailY);
    path.close();

    canvas.drawPath(path, paint);

    // Draw three dots (ellipsis)
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotSize = bubbleSize * 0.06;
    final dotSpacing = bubbleSize * 0.15;
    final dotsY = bubbleY + bubbleSize * 0.35;
    final firstDotX = bubbleX + bubbleSize * 0.35;

    // First dot
    canvas.drawCircle(Offset(firstDotX, dotsY), dotSize, dotPaint);

    // Second dot
    canvas.drawCircle(Offset(firstDotX + dotSpacing, dotsY), dotSize, dotPaint);

    // Third dot
    canvas.drawCircle(
      Offset(firstDotX + dotSpacing * 2, dotsY),
      dotSize,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
