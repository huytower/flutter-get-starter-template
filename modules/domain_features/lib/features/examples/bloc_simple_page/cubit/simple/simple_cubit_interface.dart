import 'package:bloc/bloc.dart';

import 'simple_cubit_state.dart';

/// Interface for the SimpleCubit to improve testability and follow DIP
abstract class SimpleCubitInterface extends Cubit<SimpleCubitState> {
  SimpleCubitInterface(SimpleCubitState state) : super(state);

  /// Increases the counter by 1
  Future<void> increase();

  /// Resets the counter to 0
  Future<void> reset();

  /// Clears any error message
  void clearError();
}
