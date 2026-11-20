import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/features/report/domain/usecases/generate_ai_financial_advice_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GenerateAiFinancialAdviceUseCase.failureFor', () {
    test('a device attestation failure becomes device_not_genuine', () {
      final failure = GenerateAiFinancialAdviceUseCase.failureFor(
        const CcAiFailure(CcAiFailureKind.deviceAttestation),
      );

      expect(failure, isA<ValidationFailure>());
      expect(
        failure.message,
        GenerateAiFinancialAdviceUseCase.deviceNotGenuineReason,
      );
    });

    test('any other failure becomes an empty-response server failure', () {
      for (final aiFailure in [
        const CcAiFailure(CcAiFailureKind.unknown),
        null,
      ]) {
        final failure = GenerateAiFinancialAdviceUseCase.failureFor(aiFailure);

        expect(failure, isA<ServerFailure>());
        expect(
          failure.message,
          GenerateAiFinancialAdviceUseCase.emptyResponseReason,
        );
      }
    });
  });
}
