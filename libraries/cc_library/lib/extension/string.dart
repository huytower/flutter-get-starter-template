extension StringExtension on String {
  String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
}
