import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/counter_entity.dart';
import '../repositories/counter_repository.dart';

@lazySingleton
class IncrementCounterUseCase {
  final CounterRepository repository;

  IncrementCounterUseCase(this.repository);

  Future<Result<CounterEntity, CcFailure>> call(CounterEntity current) async {
    final updated = current.copyWith(value: current.value + 1);
    final result = await repository.saveCounter(updated);

    return result.when((success) => Success(updated), (error) => Error(error));
  }
}
