/// Custom exception thrown when the server returns a successful HTTP status
/// but the business logic status (the "status" field in the JSON) is false.
class CcServerException implements Exception {
  final String message;
  final String? code;
  final Map<String, List<String>>? errors;

  CcServerException({required this.message, this.code, this.errors});

  @override
  String toString() => 'CcServerException: $message (code: $code)';
}
