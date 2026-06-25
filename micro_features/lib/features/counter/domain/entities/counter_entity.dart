class CounterEntity {
  final int value;

  const CounterEntity({required this.value});

  CounterEntity copyWith({int? value}) {
    return CounterEntity(value: value ?? this.value);
  }
}
