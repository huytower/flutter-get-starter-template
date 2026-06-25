import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/counter_entity.dart';
import '../../domain/usecases/decrement_counter_usecase.dart';
import '../../domain/usecases/get_counter_usecase.dart';
import '../../domain/usecases/increment_counter_usecase.dart';

part 'counter_event.dart';
part 'counter_state.dart';

@injectable
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  final GetCounterUseCase getCounterUseCase;
  final IncrementCounterUseCase incrementCounterUseCase;
  final DecrementCounterUseCase decrementCounterUseCase;

  CounterBloc({
    required this.getCounterUseCase,
    required this.incrementCounterUseCase,
    required this.decrementCounterUseCase,
  }) : super(CounterInitial()) {
    on<LoadCounterEvent>(_onLoadCounter);
    on<IncrementCounterEvent>(_onIncrementCounter);
    on<DecrementCounterEvent>(_onDecrementCounter);
  }

  Future<void> _onLoadCounter(
    LoadCounterEvent event,
    Emitter<CounterState> emit,
  ) async {
    emit(CounterLoading());
    final result = await getCounterUseCase();

    result.when(
      (counter) => emit(CounterLoaded(counter: counter)),
      (failure) => emit(CounterError(message: failure.message)),
    );
  }

  Future<void> _onIncrementCounter(
    IncrementCounterEvent event,
    Emitter<CounterState> emit,
  ) async {
    final currentState = state;
    if (currentState is CounterLoaded) {
      final result = await incrementCounterUseCase(currentState.counter);

      result.when(
        (updatedCounter) => emit(CounterLoaded(counter: updatedCounter)),
        (failure) => emit(CounterError(message: failure.message)),
      );
    }
  }

  Future<void> _onDecrementCounter(
    DecrementCounterEvent event,
    Emitter<CounterState> emit,
  ) async {
    final currentState = state;
    if (currentState is CounterLoaded) {
      final result = await decrementCounterUseCase(currentState.counter);

      result.when(
        (updatedCounter) => emit(CounterLoaded(counter: updatedCounter)),
        (failure) => emit(CounterError(message: failure.message)),
      );
    }
  }
}
