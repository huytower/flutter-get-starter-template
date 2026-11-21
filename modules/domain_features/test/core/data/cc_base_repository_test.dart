import 'package:cc_sdk/export_cc_sdk.dart'
    show CcCrashReporter, CcServerException;
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/data/repository/cc_base_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCrashReporter implements CcCrashReporter {
  final List<Object> errors = [];
  final List<String> reasons = [];

  @override
  Future<void> log(String message) async {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    required String reason,
    bool fatal = false,
  }) async {
    errors.add(error);
    reasons.add(reason);
  }
}

class _Repository with CcBaseRepository {
  _Repository(this.crashReporter);

  @override
  final CcCrashReporter crashReporter;
}

void main() {
  late _FakeCrashReporter reporter;
  late _Repository repository;

  setUp(() {
    reporter = _FakeCrashReporter();
    repository = _Repository(reporter);
  });

  test('reports an unexpected exception and maps it to a failure', () async {
    final result = await repository.safeRequest<int>(
      () async => throw StateError('Liability 1 not found'),
    );

    expect(result.tryGetError(), isA<ServerFailure>());
    expect(reporter.errors.single, isA<StateError>());
    expect(reporter.reasons.single, '_Repository.safeRequest');
  });

  test('does not report an expected server failure', () async {
    final result = await repository.safeRequest<int>(
      () async => throw CcServerException(message: 'Bad request'),
    );

    expect(result.tryGetError(), isA<ServerFailure>());
    expect(reporter.errors, isEmpty);
  });

  test('does not report a success', () async {
    final result = await repository.safeRequest(() async => 1);

    expect(result.tryGetSuccess(), 1);
    expect(reporter.errors, isEmpty);
  });
}
