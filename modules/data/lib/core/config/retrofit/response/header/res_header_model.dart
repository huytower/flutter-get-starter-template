import 'package:json_annotation/json_annotation.dart';

part 'res_header_model.g.dart';

/// Standard header/envelope part of a REST API response.
///
/// This model is designed to be extremely robust. It will NOT crash
/// if the backend fails to send specific fields.
@JsonSerializable()
class ResHeaderModel {
  /// Boolean success flag. Defaults to `false` if missing.
  @JsonKey(defaultValue: false)
  final bool status;

  /// Human-readable message from the server. Defaults to empty string if missing.
  @JsonKey(defaultValue: '')
  final String message;

  /// Business logic status code (e.g., '0' for success).
  final String? code;

  /// Total number of items (useful for pagination root responses).
  final int? total;

  /// General error message or detail.
  final String? error;

  /// Map of validation errors (e.g., {"field": ["error message"]}).
  final Map<String, List<String>>? errors;

  /// Metadata for pagination, server time, etc.
  final Map<String, dynamic>? meta;

  const ResHeaderModel({
    this.status = false,
    this.message = '',
    this.code,
    this.total,
    this.error,
    this.errors,
    this.meta,
  });

  factory ResHeaderModel.fromJson(Map<String, dynamic> json) =>
      _$ResHeaderModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResHeaderModelToJson(this);
}
