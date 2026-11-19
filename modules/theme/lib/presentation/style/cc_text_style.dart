import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../data/data_source/color/prj_color.dart';

/// A collection of text styles following Material Design guidelines.
///
/// This class implements ThemeExtension for better theming support and provides
/// consistent typography across the application.
///
/// ## Usage
///
/// ```dart
/// // In your theme configuration:
/// MaterialApp(
///   theme: ThemeData(
///     extensions: <ThemeExtension<dynamic>>[
///       CcTextStyle.light(),
///     ],
///   ),
///   darkTheme: ThemeData.dark().copyWith(
///     extensions: <ThemeExtension<dynamic>>[
///       CcTextStyle.dark(),
///     ],
///   ),
/// );
///
/// // In your widgets:
/// Text(
///   'Hello World',
///   style: Theme.of(context).extension<CcTextStyle>()?.displayLarge,
/// )
/// ```
class CcTextStyle extends ThemeExtension<CcTextStyle> {
  // Typography tokens are defined in CcTypographyParams (cc_sdk_ui)

  // Display Styles (Material 3)
  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;

  // Headline Styles
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;

  // Title Styles
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;

  // Body Styles
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;

  // Label Styles
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;

  /// Creates a [CcTextStyle] with the given styles.
  const CcTextStyle({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
  });

  /// Creates a light theme text style configuration.
  factory CcTextStyle.light() {
    return const CcTextStyle(
      // Display Styles
      displayLarge: TextStyle(
        fontWeight: CcTypographyParams.regular,
        fontSize: CcTypographyParams.displayLarge,
        height: 1.12,
        color: PrjColors.highEmphasis,
      ),
      displayMedium: TextStyle(
        fontWeight: CcTypographyParams.regular,
        fontSize: CcTypographyParams.displayMedium,
        height: 1.16,
        color: PrjColors.highEmphasis,
      ),
      displaySmall: TextStyle(
        fontWeight: CcTypographyParams.regular,
        fontSize: CcTypographyParams.displaySmall,
        height: 1.22,
        color: PrjColors.highEmphasis,
      ),

      // Headline Styles
      headlineLarge: TextStyle(
        fontWeight: CcTypographyParams.regular,
        fontSize: CcTypographyParams.headlineLarge,
        height: 1.25,
        color: PrjColors.highEmphasis,
      ),
      headlineMedium: TextStyle(
        fontWeight: CcTypographyParams.medium,
        fontSize: CcTypographyParams.headlineMedium,
        height: 1.29,
        color: PrjColors.highEmphasis,
      ),
      headlineSmall: TextStyle(
        fontWeight: CcTypographyParams.semiBold,
        fontSize: CcTypographyParams.headlineSmall,
        height: 1.33,
        color: PrjColors.highEmphasis,
      ),

      // Title Styles
      titleLarge: TextStyle(
        fontWeight: CcTypographyParams.medium,
        fontSize: CcTypographyParams.titleLarge,
        height: 1.27,
        color: PrjColors.highEmphasis,
      ),
      titleMedium: TextStyle(
        fontWeight: CcTypographyParams.medium,
        fontSize: CcTypographyParams.titleMedium,
        letterSpacing: 0.1,
        height: 1.5,
        color: PrjColors.highEmphasis,
      ),
      titleSmall: TextStyle(
        fontWeight: CcTypographyParams.medium,
        fontSize: CcTypographyParams.titleSmall,
        letterSpacing: 0.1,
        height: 1.43,
        color: PrjColors.highEmphasis,
      ),

      // Body Styles
      bodyLarge: TextStyle(
        fontWeight: CcTypographyParams.regular,
        fontSize: CcTypographyParams.bodyLarge,
        letterSpacing: 0.5,
        height: 1.5,
        color: PrjColors.highEmphasis,
      ),
      bodyMedium: TextStyle(
        fontWeight: CcTypographyParams.regular,
        fontSize: CcTypographyParams.bodyMedium,
        letterSpacing: 0.25,
        height: 1.43,
        color: PrjColors.mediumEmphasis,
      ),
      bodySmall: TextStyle(
        fontWeight: CcTypographyParams.regular,
        fontSize: CcTypographyParams.bodySmall,
        letterSpacing: 0.4,
        height: 1.33,
        color: PrjColors.hint,
      ),

      // Label Styles
      labelLarge: TextStyle(
        fontWeight: CcTypographyParams.medium,
        fontSize: CcTypographyParams.labelLarge,
        letterSpacing: 0.1,
        height: 1.43,
        color: PrjColors.highEmphasis,
      ),
      labelMedium: TextStyle(
        fontWeight: CcTypographyParams.medium,
        fontSize: CcTypographyParams.labelMedium,
        height: 1.33,
        color: PrjColors.mediumEmphasis,
      ),
      labelSmall: TextStyle(
        fontWeight: CcTypographyParams.medium,
        fontSize: CcTypographyParams.labelSmall,
        height: 1.45,
        color: PrjColors.hint,
      ),
    );
  }

  /// Creates a dark theme text style configuration.
  factory CcTextStyle.dark() {
    final light = CcTextStyle.light();
    return CcTextStyle(
      // Update colors for dark theme
      displayLarge: light.displayLarge.copyWith(color: PrjColors.onSurface),
      displayMedium: light.displayMedium.copyWith(color: PrjColors.onSurface),
      displaySmall: light.displaySmall.copyWith(color: PrjColors.onSurface),

      headlineLarge: light.headlineLarge.copyWith(color: PrjColors.onSurface),
      headlineMedium: light.headlineMedium.copyWith(color: PrjColors.onSurface),
      headlineSmall: light.headlineSmall.copyWith(color: PrjColors.onSurface),

      titleLarge: light.titleLarge.copyWith(color: PrjColors.onSurface),
      titleMedium: light.titleMedium.copyWith(color: PrjColors.onSurface),
      titleSmall: light.titleMedium.copyWith(color: PrjColors.mediumEmphasis),

      bodyLarge: light.bodyLarge.copyWith(color: PrjColors.onSurface),
      bodyMedium: light.bodyMedium.copyWith(color: PrjColors.mediumEmphasis),
      bodySmall: light.bodySmall.copyWith(color: PrjColors.hint),

      labelLarge: light.labelLarge.copyWith(color: PrjColors.onSurface),
      labelMedium: light.labelMedium.copyWith(color: PrjColors.mediumEmphasis),
      labelSmall: light.labelSmall.copyWith(color: PrjColors.hint),
    );
  }

  @override
  ThemeExtension<CcTextStyle> copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
  }) {
    return CcTextStyle(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      displaySmall: displaySmall ?? this.displaySmall,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      titleSmall: titleSmall ?? this.titleSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      labelSmall: labelSmall ?? this.labelSmall,
    );
  }

  @override
  ThemeExtension<CcTextStyle> lerp(
    ThemeExtension<CcTextStyle>? other,
    double t,
  ) {
    if (other is! CcTextStyle) {
      return this;
    }
    return CcTextStyle(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
    );
  }

  /// Returns the text theme for Material 3.
  TextTheme get textTheme {
    return TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }
}

