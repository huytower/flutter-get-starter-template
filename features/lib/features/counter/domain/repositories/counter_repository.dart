import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/counter_entity.dart';

abstract class CounterRepository {
  Future<Result<CounterEntity, Failure>> getCounter();

  Future<Result<Unit, Failure>> saveCounter(CounterEntity counter);
}
