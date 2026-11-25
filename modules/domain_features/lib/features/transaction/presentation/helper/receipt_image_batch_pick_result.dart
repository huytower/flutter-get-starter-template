import 'receipt_image.dart';

class ReceiptImageBatchPickResult {
  const ReceiptImageBatchPickResult({
    this.images = const [],
    this.permissionDenied = false,
    this.failed = false,
  });

  final List<ReceiptImage> images;
  final bool permissionDenied;
  final bool failed;
}

