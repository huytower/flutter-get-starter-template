/// BLOC : EVENT
/// Step 2 : create Event
/// - state : notify data set changed, by using method `add(new Event())`
///
abstract class AdvanceBlocEvent {}

class InitEvent extends AdvanceBlocEvent {}

class IncreaseEvent extends AdvanceBlocEvent {}
