import 'dart:typed_data';

import 'package:flutter/services.dart' show PlatformException;
import 'package:image_picker/image_picker.dart';

/// A receipt/screenshot image picked via [ReceiptImagePickerHelper.pickReceiptImage]
/// — carries the file path plus the raw bytes
/// and real [mimeType] (the cloud vision parser needs both). Not
/// [XFile] itself, so callers never need a direct `image_picker` dependency.
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

/// Outcome of [ReceiptImagePickerHelper.pickReceiptImage] — distinguishes *why*
/// [image] is null so callers can show "permission denied" vs. silently
/// no-op on a plain cancel.
class ReceiptImagePickResult {
  const ReceiptImagePickResult({this.image, this.permissionDenied = false});

  final ReceiptImage? image;
  final bool permissionDenied;
}

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

/// Picks receipt images (camera or gallery) as [ReceiptImage]s.
/// Fails silently on any error — backs a best-effort local extraction that
/// must degrade gracefully rather than crash.
abstract final class ReceiptImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();
  static const double _maxImageDimension = 2048;

  static Future<ReceiptImagePickResult> pickReceiptImage({
    required bool fromCamera,
  }) async {
    try {
      // imageQuality isn't a reliable JPEG guarantee — both platforms skip
      // re-encoding for images with an alpha channel (most PNG screenshots).
      // Sniff the real format from the bytes instead.
      final file = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: _maxImageDimension,
        maxHeight: _maxImageDimension,
        imageQuality: 85,
      );
      if (file == null) return const ReceiptImagePickResult();
      final image = await _toPickedImage(file);
      if (image == null) return const ReceiptImagePickResult();
      return ReceiptImagePickResult(image: image);
    } on PlatformException catch (e) {
      return ReceiptImagePickResult(permissionDenied: _isPermissionDenied(e));
    } catch (_) {
      return const ReceiptImagePickResult();
    }
  }

  static Future<ReceiptImageBatchPickResult> pickReceiptImages({
    required int limit,
  }) async {
    try {
      final files = await _picker.pickMultiImage(
        maxWidth: _maxImageDimension,
        maxHeight: _maxImageDimension,
        imageQuality: 85,
        limit: limit,
      );
      final images = <ReceiptImage>[];
      for (final file in files.take(limit)) {
        final image = await _toPickedImage(file);
        if (image == null)
          return const ReceiptImageBatchPickResult(failed: true);
        images.add(image);
      }
      return ReceiptImageBatchPickResult(images: images);
    } on PlatformException catch (e) {
      return ReceiptImageBatchPickResult(
        permissionDenied: _isPermissionDenied(e),
      );
    } catch (_) {
      return const ReceiptImageBatchPickResult(failed: true);
    }
  }

  static Future<ReceiptImage?> _toPickedImage(XFile file) async {
    final bytes = await file.readAsBytes();
    final mimeType = _detectImageMimeType(bytes);
    if (mimeType == null) return null;
    return ReceiptImage(path: file.path, bytes: bytes, mimeType: mimeType);
  }

  // image_picker_android/image_picker_ios both use these exact codes
  // for a denied camera or photo-library permission.
  static bool _isPermissionDenied(PlatformException e) =>
      e.code == 'camera_access_denied' || e.code == 'photo_access_denied';

  /// Sniffs the format from the magic-number header; null (not a guessed
  /// JPEG) on an unrecognized signature, so a corrupt file fails the pick
  /// rather than reaching the cloud fallback under a wrong MIME type.
  static String? _detectImageMimeType(Uint8List bytes) {
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }
    return null;
  }
}
