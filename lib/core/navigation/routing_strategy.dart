import 'package:cc_micro_features/export_micro_features.dart'
    show CcMfTranslations;
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:message/export_message.dart';
import 'package:provider/provider.dart';
import 'package:theme/presentation/provider/theme_provider.dart';

/// A strategy that builds the app shell and router widget.
///
/// This class isolates routing implementation details from app setup logic.
/// The shared theme and localization wiring is handled in one place.
abstract class RoutingStrategy {
  final ThemeProvider _themeProvider;

  const RoutingStrategy(this._themeProvider);

  /// Builds the fully-configured application widget.
  Widget buildApp();

  /// Wraps the router with shared app-level wiring.
  ///
  /// This keeps theme/localization/provider setup in one location and makes
  @protected
  Widget buildThemedApp(
    Widget Function(BuildContext context, ThemeProvider themeProvider)
    routerBuilder,
  ) {
    return ChangeNotifierProvider<ThemeProvider>.value(
      value: _themeProvider,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return CcLocalization.wrapWithLocalization(
            packageTranslations: const [CcMfTranslations.mapLocales],
            child: Builder(
              builder: (context) => routerBuilder(context, themeProvider),
            ),
          );
        },
      ),
    );
  }

  /// Resources are owned by DI, so override only if this strategy needs cleanup.
  @disposeMethod
  @mustCallSuper
  void dispose() {}
}
