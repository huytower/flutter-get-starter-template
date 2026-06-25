import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/counter_entity.dart';
import '../models/counter_model.dart';

abstract class CounterLocalDataSource {
  Future<CounterEntity> getCounter();

  Future<void> saveCounter(CounterEntity counter);
}

@LazySingleton(as: CounterLocalDataSource)
class CounterLocalDataSourceImpl implements CounterLocalDataSource {
  static const _counterKey = 'counter_value';
  final SharedPreferences sharedPreferences;

  CounterLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<CounterEntity> getCounter() async {
    final value = sharedPreferences.getInt(_counterKey) ?? 0;
    return CounterModel(value: value);
  }

  @override
  Future<void> saveCounter(CounterEntity counter) async {
    await sharedPreferences.setInt(_counterKey, counter.value);
  }
}
