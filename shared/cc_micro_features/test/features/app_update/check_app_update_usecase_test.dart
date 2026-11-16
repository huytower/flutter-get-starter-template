import 'package:cc_micro_features/features/app_update/domain/entities/app_update_config_entity.dart';
import 'package:cc_micro_features/features/app_update/domain/entities/app_update_status_entity.dart';
import 'package:cc_micro_features/features/app_update/domain/entities/app_version_entity.dart';
import 'package:cc_micro_features/features/app_update/domain/entities/installed_app_entity.dart';
import 'package:cc_micro_features/features/app_update/domain/repositories/app_update_config_repository.dart';
import 'package:cc_micro_features/features/app_update/domain/repositories/app_update_repository.dart';
import 'package:cc_micro_features/features/app_update/domain/usecases/check_app_update_usecase.dart';
import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';

class _FakeConfigRepository implements AppUpdateConfigRepository {
  _FakeConfigRepository(this.result);

  final Result<AppUpdateConfigEntity, CcFailure> result;

  @override
  Future<Result<AppUpdateConfigEntity, CcFailure>> getConfig() async => result;
}

class _FakeAppRepository implements AppUpdateRepository {
  _FakeAppRepository(this.result);

  final Result<InstalledAppEntity, CcFailure> result;
  int calls = 0;

  @override
  Future<Result<InstalledAppEntity, CcFailure>> getInstalledApp() async {
    calls++;
    return result;
  }

  @override
  Future<Result<Unit, CcFailure>> openStore({
    String? iosAppStoreId,
    String? androidPackageName,
  }) async => const Success(unit);
}

InstalledAppEntity installed(String version, {bool store = true}) =>
    InstalledAppEntity(
      version: AppVersionEntity.tryParse(version)!,
      packageName: 'com.example.app',
      isStoreDistributed: store,
    );

AppUpdateConfigEntity config({required bool isForce, String? minimum}) =>
    AppUpdateConfigEntity(isForce: isForce, minimumVersion: minimum);

void main() {
  group('CheckAppUpdateUseCase.evaluate', () {
    test('requires an update when forced and installed < minimum', () {
      final status = CheckAppUpdateUseCase.evaluate(
        config(isForce: true, minimum: '1.2.0'),
        installed('1.1.9+40'),
      );
      expect(status, isA<AppUpdateRequired>());
      final required = status as AppUpdateRequired;
      expect(required.currentVersion.toString(), '1.1.9+40');
      expect(required.minimumVersion.toString(), '1.2.0');
    });

    test('no update when the installed version meets the minimum', () {
      for (final current in ['1.2.0+1', '1.2.1', '2.0.0']) {
        expect(
          CheckAppUpdateUseCase.evaluate(
            config(isForce: true, minimum: '1.2.0'),
            installed(current),
          ),
          const AppUpdateNotRequired(),
          reason: current,
        );
      }
    });

    test('isForce false never blocks, even far below the minimum', () {
      expect(
        CheckAppUpdateUseCase.evaluate(
          config(isForce: false, minimum: '9.0.0'),
          installed('1.0.0+1'),
        ),
        const AppUpdateNotRequired(),
      );
    });

    test('missing or invalid minimum never blocks', () {
      for (final minimum in [
        null,
        '',
        'YOUR_MINIMUM_OS_VERSION_HAS_FORCE_HERE',
      ]) {
        expect(
          CheckAppUpdateUseCase.evaluate(
            config(isForce: true, minimum: minimum),
            installed('1.0.0+1'),
          ),
          const AppUpdateNotRequired(),
          reason: '$minimum',
        );
      }
    });

    test('platforms without a store are never blocked', () {
      expect(
        CheckAppUpdateUseCase.evaluate(
          config(isForce: true, minimum: '9.0.0'),
          installed('1.0.0', store: false),
        ),
        const AppUpdateNotRequired(),
      );
    });

    test('build-number minimum blocks older builds of the same version', () {
      expect(
        CheckAppUpdateUseCase.evaluate(
          config(isForce: true, minimum: '1.0.0+26'),
          installed('1.0.0+25'),
        ),
        isA<AppUpdateRequired>(),
      );
    });
  });

  group('CheckAppUpdateUseCase.call', () {
    test('skips the device lookup when force is off', () async {
      final appRepo = _FakeAppRepository(Success(installed('1.0.0')));
      final useCase = CheckAppUpdateUseCase(
        _FakeConfigRepository(Success(config(isForce: false))),
        appRepo,
      );

      final result = await useCase();

      expect(result.tryGetSuccess(), const AppUpdateNotRequired());
      expect(appRepo.calls, 0);
    });

    test('returns AppUpdateRequired end to end', () async {
      final useCase = CheckAppUpdateUseCase(
        _FakeConfigRepository(
          Success(config(isForce: true, minimum: '1.1.0')),
        ),
        _FakeAppRepository(Success(installed('1.0.0+25'))),
      );

      final result = await useCase();

      expect(result.tryGetSuccess(), isA<AppUpdateRequired>());
    });

    test('propagates config and device failures', () async {
      const failure = UnknownFailure('boom');
      final configFails = CheckAppUpdateUseCase(
        _FakeConfigRepository(const Error(failure)),
        _FakeAppRepository(Success(installed('1.0.0'))),
      );
      final deviceFails = CheckAppUpdateUseCase(
        _FakeConfigRepository(
          Success(config(isForce: true, minimum: '2.0.0')),
        ),
        _FakeAppRepository(const Error(DeviceFailure('no info'))),
      );

      expect((await configFails()).tryGetError(), failure);
      expect(
        (await deviceFails()).tryGetError(),
        const DeviceFailure('no info'),
      );
    });
  });
}
