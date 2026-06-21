import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/counter_entity.dart';

abstract class CounterRepository {
  Future<Result<CounterEntity, CcFailure>> getCounter();

  Future<Result<Unit, CcFailure>> saveCounter(CounterEntity counter);
}
