import 'package:domain_features/core/contracts/user_level_provider.dart';
import 'package:domain_features/features/profile/domain/usecases/get_profile_settings_usecase.dart';
import 'package:domain_features/features/profile/domain/usecases/update_profile_settings_usecase.dart';
import 'package:injectable/injectable.dart';

/// The one rule for emergency-fund wallets, shared by the wallet list and the
/// add-wallet sheet.
///
/// The type is offered from level 3 (or VIP); it can be created once the user
/// is VIP, or is level 3 and has read the emergency-fund ebook.
@injectable
class EmergencyFundAccess {
  EmergencyFundAccess(this._userLevel, this._getSettings, this._updateSettings);

  final UserLevelProvider _userLevel;
  final GetProfileSettingsUseCase _getSettings;
  final UpdateProfileSettingsUseCase _updateSettings;

  /// Whether the emergency-fund type is shown at all.
  bool get hasOffered {
    final status = _userLevel.status;
    return status.level >= 3 || status.hasVip;
  }

  /// Whether an emergency-fund wallet may be created now.
  Future<bool> isUnlocked() async {
    final settings = await _getSettings();
    return settings.hasVip ||
        (_userLevel.status.level >= 3 && settings.hasViewedEmergencyFundEbook);
  }

  /// Records that the user opened the emergency-fund ebook.
  Future<void> markEbookViewed() async {
    final settings = await _getSettings();
    await _updateSettings(settings.copyWith(hasViewedEmergencyFundEbook: true));
  }
}
