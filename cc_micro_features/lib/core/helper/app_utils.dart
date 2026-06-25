/// Common utility functions used across features
class AppUtils {
  /// Validates if a string is a valid email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Formats a DateTime to a readable string
  static String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    // Implementation using intl package if needed
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// Debounces a function call
  static Function debounce(Function fn, [int milliseconds = 300]) {
    return () {
      // Implementation here
    };
  }
}
