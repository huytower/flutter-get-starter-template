import 'package:cc_sdk/export_cc_sdk.dart';

/// Central route name definitions for the app.
///
/// This file keeps route identifiers and path generation in one place.
/// It is used for application routes and example/demo routes.

enum AppRoute {
  splash,
  dashboard,
  setting,
  login,
  phoneAuth,
  logout,
  profile,
  updateVersion,
  web,
  comment,
  commentDetail,
  featuresCounter,
  mainNavigation,
}

extension AppRoutePath on AppRoute {
  String get path {
    if (this == AppRoute.mainNavigation) {
      return CcRouteConfig.mainNavigation;
    }
    if (this == AppRoute.login) {
      return CcRouteConfig.login;
    }
    return '/${_snakeCase(name)}';
  }
}

enum ExampleRoute { blocSimple, blocAdvance, getxSimple, getxSimpleV2 }

extension ExampleRoutePath on ExampleRoute {
  String get path => '/${_snakeCase(name)}';
}

AppRoute? appRouteFromString(String? raw) {
  final normalized = _normalizeRouteKey(raw);
  try {
    return AppRoute.values.firstWhere(
      (route) => _snakeCase(route.name).toUpperCase() == normalized,
    );
  } catch (_) {
    return null;
  }
}

ExampleRoute? exampleRouteFromString(String? raw) {
  final normalized = _normalizeRouteKey(raw);
  try {
    return ExampleRoute.values.firstWhere(
      (route) => _snakeCase(route.name).toUpperCase() == normalized,
    );
  } catch (_) {
    return null;
  }
}

String _snakeCase(String input) {
  return input
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match[1]}_${match[2]}',
      )
      .toLowerCase();
}

String _normalizeRouteKey(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return '';
  }

  return raw
      .trim()
      .replaceAll(RegExp(r'[\s\-]+'), '_')
      .replaceAll(RegExp(r'__+'), '_')
      .toUpperCase();
}
