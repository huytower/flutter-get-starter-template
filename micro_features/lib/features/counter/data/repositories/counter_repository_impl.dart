import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../domain/entities/counter_entity.dart';
import '../../domain/repositories/counter_repository.dart';
import '../datasources/counter_local_data_source.dart';

@LazySingleton(as: CounterRepository)
class CounterRepositoryImpl implements CounterRepository {
  final CounterLocalDataSource localDataSource;

  CounterRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<CounterEntity, CcFailure>> getCounter() async {
    try {
      final result = await localDataSource.getCounter();
      return Success(result);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<Unit, CcFailure>> saveCounter(CounterEntity counter) async {
    try {
      await localDataSource.saveCounter(counter);
      return const Success(unit);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }
}
