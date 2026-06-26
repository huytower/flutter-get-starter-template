import 'package:deep_collection/deep_collection.dart';

///https://www.programiz.com/kotlin-programming/when-expression
/// [ccWhen] can be used as a statement with or without else branch. If it is used as a statement,
/// the values of all individual branches are compared sequentially with the argument and execute
/// the corresponding branch where the condition matches. If none of the branches is satisfied
/// with the condition then it will execute the else branch.
///
dynamic ccWhen<T, R>({T? variable, Map<T, R>? conditions, R? orElse}) {
  var isDefault = true;
  dynamic result;
  if (conditions != null) {
    Map<T, R>? _conditions = conditions.deepReverse();
    _conditions.forEach((key, _value) {
      if (variable != null) {
        var containsKey = key == variable;
        if (containsKey) {
          isDefault = false;
          result = _value;
        }
      } else {
        if (key == true) {
          isDefault = false;
          result = _value;
        }
      }
    });
  }
  if ((orElse != null) && (isDefault == true)) {
    result = orElse;
  }
  if (result is Function) {
    return result?.call();
  } else {
    return result;
  }
}
