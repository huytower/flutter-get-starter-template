import 'package:flutter/material.dart';

/// CcBaseColors: The "Palette" for the UI Library.
///
/// This file defines raw primitives (hex codes) and standardized color steps.
/// It acts as the "Paint Box" shared across multiple projects.
///
/// ## Principles
/// - **Primitives Only**: Do not define semantic roles (like 'actionPrimary') here.
/// - **Project Agnostic**: This file should be reusable in any app.
///
/// ## Best Practices
/// - All colors are [const] for performance.
/// - Opacity is handled via 8-digit hex (AARRGGBB).
class CcBaseColors {
  // ===========================================================================
  // PRIMITIVES (The Palette)
  // ===========================================================================

  // -- Neutral Palette (Slate/Zinc Style)
  static const Color neutral100 = Color(0xFF000000);
  static const Color neutral90 = Color(0xE6000000);
  static const Color neutral80 = Color(0xCC000000);
  static const Color neutral70 = Color(0xB3000000);
  static const Color neutral50 = Color(0x80000000);
  static const Color neutral40 = Color(0x66000000);
  static const Color neutral30 = Color(0x4D000000);
  static const Color neutral20 = Color(0x33000000);
  static const Color neutral10 = Color(0x1A000000);
  static const Color neutral5 = Color(0x0D000000);

  static const Color white100 = Color(0xFFFFFFFF);
  static const Color white80 = Color(0xCCFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color white40 = Color(0x66FFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color white15 = Color(0x26FFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);

  // -- Gray Scale
  static const Color gray950 = Color(0xFF16181C);
  static const Color gray900 = Color(0xFF111827);
  static const Color gray800 = Color(0xFF1E2126);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray50 = Color(0xFFF9FAFB);

  // -- Indigo (Popular Modern Brand)
  static const Color indigo900 = Color(0xFF312E81);
  static const Color indigo700 = Color(0xFF4338CA);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo100 = Color(0xFFE0E7FF);

  // -- Violet
  static const Color violet600 = Color(0xFF7C3AED);
  static const Color violet500 = Color(0xFF8B5CF6);

  // -- Teal & Emerald (Financial/Success)
  static const Color teal600 = Color(0xFF0D9488);
  static const Color teal500 = Color(0xFF14B8A6);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald500 = Color(0xFF10B981);

  // -- Brand Palette (Original Pink)
  static const Color brand900 = Color(0xFF880E4F);
  static const Color brand800 = Color(0xFFAD1457);
  static const Color brand700 = Color(0xFFC2185B);
  static const Color brand600 = Color(0xFFD81B60);
  static const Color brand500 = Color(0xFFE91E63);
  static const Color brand300 = Color(0xFFF06292);
  static const Color brand100 = Color(0xFFF8BBD0);

  // -- Secondary Palette (Modern Blue)
  static const Color blue900 = Color(0xFF1E3A8A);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue100 = Color(0xFFDBEAFE);

  // -- Yellow Palette (Modern/Trending)
  static const Color yellow900 = Color(0xFF713F12);
  static const Color yellow800 = Color(0xFF854D0E);
  static const Color yellow700 = Color(0xFFA16207);
  static const Color yellow600 = Color(0xFFCA8A04);
  static const Color yellow500 = Color(0xFFEAB308);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color yellow300 = Color(0xFFFDE047);
  static const Color yellow200 = Color(0xFFFEF08A);
  static const Color yellow100 = Color(0xFFFEF9C3);
  static const Color yellow50 = Color(0xFFFEFCE8);

  // -- Status Palette
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color infoBlue = Color(0xFF3B82F6);

  // -- Utils
  static const Color transparent = Color(0x00000000);
}
