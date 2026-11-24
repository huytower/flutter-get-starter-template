import 'package:equatable/equatable.dart';

/// State class for SimpleCubit
///
/// Uses Equatable for value equality and immutability, which is the recommended
/// approach for state management in Flutter BLoC/Cubit.
class SimpleCubitState extends Equatable {
  final int counter;
  final bool hasLoading;
  final String? errorMessage;

  const SimpleCubitState({
    this.counter = 0,
    this.hasLoading = false,
    this.errorMessage,
  });

  /// Creates an initial state with default values
  static SimpleCubitState init() {
    return const SimpleCubitState(
      counter: 0,
      hasLoading: false,
      errorMessage: null,
    );
  }

  /// Creates a copy of this state with the given fields replaced with new values
  SimpleCubitState copyWith({
    int? counter,
    bool? hasLoading,
    String? errorMessage,
  }) {
    return SimpleCubitState(
      counter: counter ?? this.counter,
      hasLoading: hasLoading ?? this.hasLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [counter, hasLoading, errorMessage];
}
