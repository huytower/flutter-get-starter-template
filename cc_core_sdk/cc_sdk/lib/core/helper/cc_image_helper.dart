import 'package:path/path.dart' as p;

/// Asset path helpers for common image and animation formats.
abstract final class CcImageHelper {
  CcImageHelper._();

  static const String extensionJpg = '.jpg';
  static const String extensionLottie = '.json';
  static const String extensionPng = '.png';
  static const String extensionSvg = '.svg';

  static bool hasExtension(String path, String extension) =>
      p.extension(path).toLowerCase() == extension.toLowerCase();

  static bool isJpg(String path) => hasExtension(path, extensionJpg);

  static bool isPng(String path) => hasExtension(path, extensionPng);

  static bool isLottie(String path) => hasExtension(path, extensionLottie);

  static bool isSvg(String path) => hasExtension(path, extensionSvg);
}
