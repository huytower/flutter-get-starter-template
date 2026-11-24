import 'package:cc_micro_features/export_micro_features.dart'
    show AppReviewOptions;
import 'package:easy_localization/easy_localization.dart' as el;

/// This app's settings for the shared review sheet (`AppRatingSheet`): its
/// store ids and the feedback tags, which name this app's features.
abstract final class ProfileReviewOptions {
  static const String _iosAppId = '6738361005';
  static const String _androidPackageName = 'vn.sosachxin.finance';

  /// Shown in the "N customer ratings" line.
  static const int _totalRatings = 10;

  static const List<String> _praiseKeys = [
    'profile.feedback_praise_fast',
    'profile.feedback_praise_offline',
    'profile.feedback_praise_runway',
    'profile.feedback_praise_reconciliation',
    'profile.feedback_praise_lending',
    'profile.feedback_praise_suggestions',
    'profile.feedback_praise_interface',
    'profile.feedback_praise_scanning',
    'profile.feedback_praise_alerts',
    'profile.feedback_praise_leveling',
  ];

  static const List<String> _criticismKeys = [
    'profile.feedback_criticism_sync',
    'profile.feedback_criticism_balance',
    'profile.feedback_criticism_unlock',
    'profile.feedback_criticism_scanning',
    'profile.feedback_criticism_amount',
    'profile.feedback_criticism_categories',
    'profile.feedback_criticism_limits',
    'profile.feedback_criticism_notifications',
    'profile.feedback_criticism_charts',
    'profile.feedback_criticism_speed',
  ];

  /// The options, with the tags translated into the current language.
  static AppReviewOptions current() => AppReviewOptions(
    iosAppId: _iosAppId,
    androidPackageName: _androidPackageName,
    totalRatings: _totalRatings,
    praiseOptions: [for (final key in _praiseKeys) el.tr(key)],
    criticismOptions: [for (final key in _criticismKeys) el.tr(key)],
  );
}
