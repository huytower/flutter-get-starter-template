import 'package:domain_features/core/domain/entities/user_level_status_entity.dart';
import 'package:flutter_test/flutter_test.dart';

/// Feature gates have two independent unlock paths: the earned level, or VIP
/// (docs/BUSINESS_REQUIREMENT.md §3).
UserLevelStatusEntity _status({required int level, bool hasVip = false}) {
  return UserLevelStatusEntity(
    level: level,
    reconciliationStreak: 0,
    hasMinBudgets: false,
    hasPositiveCashFlow: false,
    fixedBudgetCount: 0,
    completedGuidelineCount: 0,
    hasVip: hasVip,
  );
}

void main() {
  group('level path (no VIP)', () {
    test('LV1 unlocks nothing', () {
      final status = _status(level: 1);
      expect(status.canUseInvestment, isFalse);
      expect(status.canUseLiability, isFalse);
      expect(status.canUseAiSmartEntry, isFalse);
    });

    test('LV2 unlocks only the Investment tab', () {
      final status = _status(level: 2);
      expect(status.canUseInvestment, isTrue);
      expect(status.canUseLiability, isFalse);
      expect(status.canUseAiSmartEntry, isFalse);
    });

    test('LV3 unlocks Investment, Liability/Lend and AI Smart Entry', () {
      final status = _status(level: 3);
      expect(status.canUseInvestment, isTrue);
      expect(status.canUseLiability, isTrue);
      expect(status.canUseAiSmartEntry, isTrue);
    });
  });

  group('VIP path', () {
    test('VIP at LV1 unlocks everything without changing the level', () {
      final status = _status(level: 1, hasVip: true);
      expect(status.level, 1);
      expect(status.canUseInvestment, isTrue);
      expect(status.canUseLiability, isTrue);
      expect(status.canUseAiSmartEntry, isTrue);
    });

    test('VIP and the level path combine without conflict', () {
      for (final level in [1, 2, 3]) {
        final status = _status(level: level, hasVip: true);
        expect(status.canUseInvestment, isTrue, reason: 'LV$level + VIP');
        expect(status.canUseLiability, isTrue, reason: 'LV$level + VIP');
      }
    });
  });

  group('LV2 guideline requirement', () {
    test('counts only the 6 LV1 tasks', () {
      const allLv1 = UserLevelStatusEntity.lv1GuidelineTaskIds;
      expect(
        UserLevelStatusEntity.countLv1GuidelineTasks(allLv1),
        UserLevelStatusEntity.lv1RequiredGuidelines,
      );
    });

    test(
      'the investment / liability tasks do not stand in for an LV1 task',
      () {
        final fiveLv1PlusLater = [
          ...UserLevelStatusEntity.lv1GuidelineTaskIds.take(5),
          'investment',
          'liability',
        ];
        expect(
          UserLevelStatusEntity.countLv1GuidelineTasks(fiveLv1PlusLater),
          5,
        );
      },
    );
  });
}
