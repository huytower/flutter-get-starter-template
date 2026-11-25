import 'receipt_image.dart';

/// Outcome of `ReceiptImagePickerHelper.pickReceiptImage` — distinguishes *why*
/// [image] is null so callers can show "permission denied" vs. silently
/// no-op on a plain cancel.
class ReceiptImagePickResult {
  const ReceiptImagePickResult({this.image, this.permissionDenied = false});

  final ReceiptImage? image;
  final bool permissionDenied;
}

