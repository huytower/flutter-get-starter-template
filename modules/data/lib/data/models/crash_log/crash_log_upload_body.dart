/// Payload for crash log upload API.
class CrashLogUploadBody {
  const CrashLogUploadBody({
    required this.appName,
    required this.uploadedAt,
    required this.logs,
  });

  final String appName;
  final String uploadedAt;
  final String logs;

  Map<String, dynamic> toJson() => {
    'appName': appName,
    'uploadedAt': uploadedAt,
    'logs': logs,
  };
}
