import '../../params/cc_rest_api_params.dart';
import '../header/cc_res_header_model.dart';

/// Standard Wrapper for RESTful API responses.
///
/// It splits the response into a "Header" (envelope) and "Data" (payload).
/// Supports both Single Object and List responses.
///
/// **Usage Example:**
/// ```dart
/// // In your repository:
/// final response = await remote.getUserProfile();
/// final user = response.flatMapToList((json) => User.fromJson(json)).firstElement;
/// ```
class CcResBodyModel<T> {
  CcResBodyModel();

  /// Contains status, message, and metadata
  CcResHeaderModel? _resHeader;

  /// Raw data as a List (unified internally)
  List<dynamic>? _resBodyList;

  /// Raw data as a Map (if the response was a single object)
  Map<String, dynamic>? _resBodyObj;

  /// The first or only element of the response data.
  /// Null if the data payload is empty.
  T? firstElement;

  /// The full list of parsed elements
  List<T> listElements = [];

  /// Getters for ease of use
  bool get isSuccess => _resHeader?.status ?? false;

  String get message => _resHeader?.message ?? '';

  int get total => _resHeader?.total ?? 0;

  String? get code => _resHeader?.code;

  Map<String, dynamic>? get meta => _resHeader?.meta;

  /// General error message or detail
  String? get error => _resHeader?.error;

  /// Map of validation errors (e.g., {"field": ["error message"]})
  Map<String, List<String>>? get errors => _resHeader?.errors;

  /// Maps the raw JSON data into typed objects [T].
  ///
  /// Example:
  /// ```dart
  /// final result = response.flatMapToList((json) => User.fromJson(json));
  /// ```
  CcResBodyModel<T> flatMapToList(
    T Function(Map<String, dynamic> json) mapper,
  ) {
    listElements.clear();

    if (_resBodyList != null) {
      for (var element in _resBodyList!) {
        if (element is Map<String, dynamic>) {
          listElements.add(mapper(element));
        }
      }
    }

    // Safely initialize firstElement if data exists
    firstElement = listElements.isNotEmpty ? listElements.first : null;

    return this;
  }

  /// Parses the response from dynamic JSON (Map).
  /// This method is robust and will not crash if fields are missing.
  CcResBodyModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return;

    // Root-level fields (status, message, code, etc.)
    // CcResHeaderModel is designed to handle missing root fields gracefully.
    _resHeader = CcResHeaderModel.fromJson(json);

    // Payload extraction
    final data = json[CcRestApiParams.data.name];

    if (data is List) {
      _resBodyList = data;
    } else if (data is Map<String, dynamic>) {
      _resBodyObj = data;
      _resBodyList = [
        data,
      ]; // Normalize single object to list for flatMapToList
    }
  }

  /// Converts the model back to a JSON Map.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    // Include header fields
    if (_resHeader != null) {
      map.addAll(_resHeader!.toJson());
    }

    // Include data
    if (_resBodyObj != null) {
      map[CcRestApiParams.data.name] = _resBodyObj;
    } else if (_resBodyList != null) {
      map[CcRestApiParams.data.name] = _resBodyList;
    }

    return map;
  }
}
