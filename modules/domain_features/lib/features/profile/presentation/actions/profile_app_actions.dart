import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/helper/ai_fallback_preference_datasource.dart';
import '../widgets/ai_consent_sheet.dart';

/// App-level choices from the profile: consent to share data with the cloud
/// AI (Gemini), and sending app feedback.
@injectable
class ProfileAppActions {
  ProfileAppActions(this._aiPreferences, this.feedbackReporter);

  final AiFallbackPreferenceDataSource _aiPreferences;

  /// Passed to the rating sheet, which sends the user's feedback.
  final CcFeedbackReporter feedbackReporter;

  Future<bool> isAiSharingEnabled() => _aiPreferences.isGeminiEnabled();

  Future<void> withdrawAiConsent() => _aiPreferences.setGeminiEnabled(false);

  /// Shows the consent sheet unless consent is already stored; true when the
  /// user allows sharing.
  Future<bool> requestAiConsent(BuildContext context) =>
      AiConsentSheet.ensure(context, _aiPreferences);
}
