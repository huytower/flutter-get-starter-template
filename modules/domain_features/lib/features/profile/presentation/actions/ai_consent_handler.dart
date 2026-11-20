import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/helper/ai_fallback_preference_datasource.dart';
import '../widgets/ai_consent_sheet.dart';

/// The user's consent to share data with the cloud AI (Gemini).
@injectable
class AiConsentHandler {
  AiConsentHandler(this._aiPreferences);

  final AiFallbackPreferenceDataSource _aiPreferences;

  Future<bool> isEnabled() => _aiPreferences.isGeminiEnabled();

  Future<void> withdraw() => _aiPreferences.setGeminiEnabled(false);

  /// Shows the consent sheet unless consent is already stored; true when the
  /// user allows sharing.
  Future<bool> request(BuildContext context) =>
      AiConsentSheet.ensure(context, _aiPreferences);
}
