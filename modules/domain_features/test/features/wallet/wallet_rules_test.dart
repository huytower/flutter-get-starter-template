import 'package:domain_features/core/contracts/user_level_provider.dart';
import 'package:domain_features/core/domain/entities/user_level_status_entity.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:domain_features/features/profile/domain/repositories/profile_repository.dart';
import 'package:domain_features/features/profile/domain/usecases/get_profile_settings_usecase.dart';
import 'package:domain_features/features/profile/domain/usecases/update_profile_settings_usecase.dart';
import 'package:domain_features/features/wallet/domain/services/emergency_fund_access.dart';
import 'package:domain_features/features/wallet/presentation/helper/wallet_ordering.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUserLevel implements UserLevelProvider {
  _FakeUserLevel({required int level, bool hasVip = false})
    : status = UserLevelStatusEntity(
        level: level,
        reconciliationStreak: 0,
        hasMinBudgets: false,
        hasPositiveCashFlow: false,
        fixedBudgetCount: 0,
        completedGuidelineCount: 0,
        hasVip: hasVip,
      );

  @override
  final UserLevelStatusEntity status;

  @override
  Future<void> refresh() async {}
}

class _FakeProfile implements ProfileRepository {
  _FakeProfile(this.settings);

  ProfileSettingsEntity settings;

  @override
  Future<ProfileSettingsEntity> getSettings() async => settings;

  @override
  Future<void> saveSettings(ProfileSettingsEntity value) async =>
      settings = value;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

EmergencyFundAccess _access(int level, ProfileRepository profile) =>
    EmergencyFundAccess(
      _FakeUserLevel(level: level),
      GetProfileSettingsUseCase(profile),
      UpdateProfileSettingsUseCase(profile),
    );

final _epoch = DateTime.utc(2026);

WalletEntity _wallet(String id, String type, {String? name, int order = 0}) =>
    WalletEntity(
      id: id,
      name: name ?? id,
      balance: 0,
      iconCode: 0,
      type: type,
      createdAt: _epoch,
      updatedAt: _epoch,
      displayOrder: order,
    );

void main() {
  group('EmergencyFundAccess', () {
    test('is offered from level 3', () {
      final profile = _FakeProfile(const ProfileSettingsEntity());
      expect(_access(2, profile).hasOffered, isFalse);
      expect(_access(3, profile).hasOffered, isTrue);
    });

    test('unlocks at level 3 only after the ebook was read', () async {
      final profile = _FakeProfile(const ProfileSettingsEntity());
      final access = _access(3, profile);

      expect(await access.isUnlocked(), isFalse);
      await access.markEbookViewed();
      expect(await access.isUnlocked(), isTrue);
    });

    test('VIP is unlocked at any level', () async {
      final profile = _FakeProfile(const ProfileSettingsEntity(hasVip: true));
      expect(await _access(0, profile).isUnlocked(), isTrue);
    });
  });

  group('WalletOrdering', () {
    test('liquid: cash, default bank, then by type and name', () {
      final ordered = WalletOrdering.liquid([
        _wallet('rainy', WalletType.emergencyFund),
        _wallet('zeta', WalletType.bank),
        _wallet('momo', WalletType.ewallet),
        _wallet(WalletOrdering.defaultBankId, WalletType.bank),
        _wallet('cash', WalletType.cash),
        _wallet('fund', WalletType.investment),
      ]);

      expect(ordered.map((w) => w.id), [
        'cash',
        WalletOrdering.defaultBankId,
        'zeta',
        'momo',
        'rainy',
      ]);
    });

    test('investment: by user order, one per id', () {
      final ordered = WalletOrdering.investment([
        _wallet('b', WalletType.investment, name: 'Stocks xyz', order: 2),
        _wallet('a', WalletType.investment, name: 'Gold xyz', order: 1),
        _wallet('a', WalletType.investment, name: 'Gold xyz', order: 1),
      ]);

      expect(ordered.map((w) => w.id), ['a', 'b']);
    });

    test('cash and the default bank cannot be deleted', () {
      expect(WalletOrdering.canDelete(_wallet('c', WalletType.cash)), isFalse);
      expect(
        WalletOrdering.canDelete(
          _wallet(WalletOrdering.defaultBankId, WalletType.bank),
        ),
        isFalse,
      );
      expect(WalletOrdering.canDelete(_wallet('x', WalletType.bank)), isTrue);
    });
  });
}
