import 'package:flutter/widgets.dart';

import 'main_tab.dart';

/// Everything the main navigation shell shows for a [MainTab]: its page, its
/// guideline badge and its refresh logic.
///
/// ```dart
/// final shell = getIt<MainShellProvider>();
/// shell.watchTabs(() => buildCurvedNavigationBar());
/// ```
abstract interface class MainShellProvider {
  /// The page shown for [tab].
  Widget buildTab(MainTab tab);

  /// The guideline badge to show on [tab]'s navigation item, or null.
  Widget? tabBadge(MainTab tab);

  /// Rebuilds [builder] whenever anything [tabBadge] depends on changes, and
  /// when the guideline asks the tabs to bounce.
  Widget watchTabs(Widget Function() builder);

  /// Reloads the data of [tab] when the user selects it.
  Future<void> refreshTab(MainTab tab);
}
