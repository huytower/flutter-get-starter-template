/// POPULAR REST API PARAMS
///
/// Standard envelope pattern for RESTful API responses.
/// Follows industry standards for mobile-backend communication.
///
/// ### How to use (Examples):
///
/// **1. Success Response (List):**
/// ```json
/// {
///   "status": true,
///   "message": "Data fetched successfully",
///   "data": [{"id": 1, "name": "Item 1"}],
///   "total": 1
/// }
/// ```
///
/// **2. Success Response (Object):**
/// ```json
/// {
///   "status": true,
///   "data": {"id": 1, "name": "User Profile"}
/// }
/// ```
///
/// **3. Error Response (General):**
/// ```json
/// {
///   "status": false,
///   "message": "Internal Server Error",
///   "error": "Database connection failed"
/// }
/// ```
///
/// **4. Validation Error (Forms):**
/// ```json
/// {
///   "status": false,
///   "message": "Validation failed",
///   "errors": {
///     "email": ["Email format is invalid"],
///     "password": ["Password is too short"]
///   }
/// }
/// ```
enum CcRestApiParams {
  /// Business status code (e.g., "0" for success, or specific error codes)
  code,

  /// Actual payload (can be a Map or List)
  data,

  /// General error detail or specific error object
  error,

  /// Map of field-specific validation errors (e.g., {"email": ["invalid format"]})
  errors,

  /// Human-readable message for UI feedback
  message,

  /// Boolean success flag for quick status checking
  status,

  /// Total count for paginated lists
  total,

  /// Metadata object for pagination details, server time, etc.
  meta,
}
