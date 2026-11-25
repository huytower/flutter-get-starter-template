import 'dart:typed_data';

/// A receipt/screenshot image picked via `ReceiptImagePickerHelper.pickReceiptImage`
/// — carries the file path plus the raw bytes
/// and real [mimeType] (the cloud vision parser needs both). Not
/// `XFile` itself, so callers never need a direct `image_picker` dependency.
class ReceiptImage {
  const ReceiptImage({
    required this.path,
    required this.bytes,
    required this.mimeType,
  });

  final String path;
  final Uint8List bytes;
  final String mimeType;
}

