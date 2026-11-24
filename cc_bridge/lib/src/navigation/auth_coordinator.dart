import 'package:flutter/widgets.dart';

/// Contract for authentication-related navigation.
///
/// This allows the Login feature to request navigation to other flows
/// (like Phone Auth or Dashboard) without knowing about their specific routes.
abstract interface class AuthCoordinator {
  /// Navigates to the Login screen.
  void navigateToLogin(BuildContext context);

  /// Navigates to the Phone Authentication screen.
  void navigateToPhoneAuth(BuildContext context);

  /// Navigates to the Main/Dashboard screen after successful login.
  void navigateToDashboard(BuildContext context);

  /// Navigates to the Terms of Service screen.
  void navigateToTerms(BuildContext context);

  /// Navigates to the Privacy Policy screen.
  void navigateToPrivacyPolicy(BuildContext context);
}
