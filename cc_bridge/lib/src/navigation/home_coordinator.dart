import 'package:flutter/widgets.dart';

/// Contract for Home/Dashboard-related navigation.
///
/// This allows the Home/Dashboard features to navigate to other services
/// like Counter, Web, or Details without being coupled to their routes.
abstract class HomeCoordinator {
  /// Navigates to a specific Web URL.
  void navigateToWeb(
    BuildContext context, {
    required String url,
    String? title,
  });
}
