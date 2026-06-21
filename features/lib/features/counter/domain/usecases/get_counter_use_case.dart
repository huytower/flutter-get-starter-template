import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/counter_entity.dart';
import '../repositories/counter_repository.dart';

@lazySingleton
class GetCounterUseCase {
  final CounterRepository repository;

  GetCounterUseCase(this.repository);

  Future<Result<CounterEntity, CcFailure>> call() async {
    return await repository.getCounter();
  }
}
