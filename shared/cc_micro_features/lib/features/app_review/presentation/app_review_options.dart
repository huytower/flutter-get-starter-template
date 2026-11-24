/// What an app tells the review sheet ([AppRatingSheet]): its store ids and the
/// feedback tags users can pick (already translated, in display order).
///
/// ```dart
/// AppReviewOptions(
///   iosAppId: '123456789',
///   androidPackageName: 'com.example.app',
///   praiseOptions: ['Fast', 'Easy to use'],
///   criticismOptions: ['Crashes', 'Slow sync'],
/// )
/// ```
class AppReviewOptions {
  const AppReviewOptions({
    this.iosAppId,
    this.androidPackageName,
    this.praiseOptions = const [],
    this.criticismOptions = const [],
    this.totalRatings = 0,
  });

  /// Numeric App Store id, for the "write a review" deep link on iOS.
  final String? iosAppId;

  /// Android application id, for the Play Store page on Android.
  final String? androidPackageName;

  /// Tags for what the user likes.
  final List<String> praiseOptions;

  /// Tags for what the user would improve.
  final List<String> criticismOptions;

  /// Number shown in the "N customer ratings" line.
  final int totalRatings;
}
