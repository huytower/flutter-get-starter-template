import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:bridge/export_bridge.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:message/export_message.dart';
import 'package:theme/export_theme.dart';

import 'logic/navigation_logic_mixin.dart';

/// Main navigation view.
///
/// Layout: Phân bổ · (＋ Giao dịch) · Hồ sơ
/// History is accessible via the action button on the Giao dịch tab.
/// Budget is accessible from the Phân bổ tab ("Xem tất cả"), not a top-level tab.
@RoutePage()
class NavigationBar extends StatefulWidget {
  const NavigationBar({super.key});

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar>
    with CcCurvedNavigationMixin, CcDoubleBackToExitMixin, NavigationLogicMixin {
  // Bar index i is MainTab.values[i]; entry ("Giao dịch") is centred as the
  // raised "＋".
  static final int _indexEntry = MainTab.entry.index;

  /// Bottom insets up to this size (dp) come from a gesture indicator (iOS home
  /// indicator, Android gesture pill); larger ones are a 3-button bar.
  static const double _maxGestureInset = 34;

  /// Padding kept under the bar for a gesture indicator — enough to clear the
  /// indicator itself. Tune on a real device if labels and indicator collide.
  static const double _gestureInsetCap = 22;

  // Singleton to persist index across hot reload.
  static int? _persistentIndex;

  /// Keeps the tab content's state when the shell switches between the
  /// bottom bar and the rail (rotation, split screen, window resize).
  final GlobalKey _contentKey = GlobalKey();

  /// Rail from expanded width up; compact and medium (phones, 7–8" tablets in
  /// portrait) keep the bottom bar they were designed for.
  bool _useRail(BuildContext context) =>
      context.windowSizeClass.isAtLeast(CcWindowSizeClass.expanded);

  @override
  void initState() {
    super.initState();
  }

  @override
  bool handleCustomNavigation() {
    if (currentIndex != _indexEntry) {
      setIndex(_indexEntry);
      return true;
    }
    return false;
  }

  @override
  double? get navigationBarHeight => context.respDim(64);

  /// [buildBottomNavigationBar] already pads for the system bottom inset
  /// (capped for gesture navigation). Letting the bar add it again doubled
  /// the inset and made the bar oversized on Android gesture devices.
  @override
  bool get navigationUseSafeArea => false;

  @override
  bool get shouldEnableDoubleBackToExit => currentIndex == _indexEntry;

  @override
  Color? get navigationActiveColor => PrjColors.primary;

  @override
  Color? get navigationActiveIconColor => PrjColors.onPrimary;

  @override
  Color? get navigationFabColor => PrjColors.primary;

  @override
  String get backPressMessage =>
      el.tr(PrjLocaleKeys.common_press_back_again_to_exit);

  @override
  void showBackPressHint(BuildContext context, String message) =>
      showDoubleBackPressSnackBar(context, message);

  @override
  int get currentIndex => _persistentIndex ?? _indexEntry;

  @override
  void setIndex(int index) {
    _persistentIndex = index;
    handleTabRefresh(index);
    setState(() {});
  }

  @override
  List<CcCurvedNavigationItem> get navigationItems => [
    CcCurvedNavigationItem(
      inactiveIcon: Icons.pie_chart_outline,
      activeIcon: Icons.pie_chart,
      label: el.tr(PrjLocaleKeys.nav_budget_allocation),
      badgeWidget: mainShell.tabBadge(MainTab.budget),
    ),
    // Centre "＋" — opens the Chi/Thu entry form.
    CcCurvedNavigationItem(
      inactiveIcon: Icons.add,
      activeIcon: Icons.add,
      label: el.tr(PrjLocaleKeys.nav_transaction),
      badgeWidget: mainShell.tabBadge(MainTab.entry),
    ),
    CcCurvedNavigationItem(
      inactiveIcon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: el.tr(PrjLocaleKeys.nav_profile),
      badgeWidget: mainShell.tabBadge(MainTab.profile),
    ),
  ];

  bool get enableAppBar => false;

  bool get enableBottomNavigationBar => !showSplash;

  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  Widget? buildBottomNavigationBar(BuildContext context) {
    final systemBottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return mainShell.watchTabs(() {
      // To support both gesture navigation and 3-button navigation without
      // overlap, we pad by the system bottom inset. A gesture indicator only
      // occupies the lower part of its inset (34dp on iPhone, ~24dp on Pixel),
      // so that case is capped to keep the bar compact; a 3-button bar fills
      // its whole inset and keeps the full padding. The background container
      // extends the color behind the system bar.
      final isGestureInset = systemBottomPadding <= _maxGestureInset;
      final bottomInset = isGestureInset
          ? math.min(systemBottomPadding, _gestureInsetCap)
          : systemBottomPadding;
      return Container(
        color: isDark ? Colors.transparent : CcBaseColors.white100,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: buildCurvedNavigationBar(),
        ),
      );
    });
  }

  /// "＋ Giao dịch" is the rail's round primary action, like the raised "＋"
  /// of the bottom bar.
  @override
  int? get navigationRailPrimaryIndex => _indexEntry;

  Widget _buildNavigationRail(BuildContext context) {
    // Labels beside icons only on desktop-class windows (≥ 1600 dp, web/PC).
    // Tablets — even a 10" one in landscape (~1280 dp) — keep the compact
    // rail so the content keeps the room.
    final extended = context.windowSizeClass.isAtLeast(
      CcWindowSizeClass.extraLarge,
    );
    return mainShell.watchTabs(
      () => buildNavigationRail(extended: extended),
    );
  }

  /// Puts the rail beside the content on wide windows. No divider: the rail's
  /// surface and the page background separate by tone. Tab pages run
  /// full-bleed and cap their own foreground (`CcMaxWidth.content`). The
  /// content subtree is keyed so switching layouts does not reset the open
  /// tab's state.
  Widget onBodyWrapper(BuildContext context, Widget body) {
    final showRail = _useRail(context) && enableBottomNavigationBar;
    return Row(
      children: [
        if (showRail) _buildNavigationRail(context),
        Expanded(
          // Lets pages square the edge that touches the rail.
          child: CcNavigationRailScope(
            railVisible: showRail,
            child: KeyedSubtree(key: _contentKey, child: body),
          ),
        ),
      ],
    );
  }

  Widget? buildContent(BuildContext context) {
    if (showSplash) {
      return const Center(child: CcLoadingIconWidget());
    }
    return mainShell.buildTab(MainTab.fromIndex(currentIndex));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = context.ccColorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: scheme.background,
            systemNavigationBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
          ),
      child: PopScope(
        canPop: canPop,
        onPopInvokedWithResult: (didPop, result) =>
            onPopInvokedWithResult(context, didPop, result),
        child: Scaffold(
          // Remove SafeArea here to allow individual pages to manage their own
          // safe area (e.g. for immersive gradient headers that span into the
          // status bar). Pages using CcViewConfigMixin (default) still get a
          // SafeArea wrapper by default unless they override useSafeArea.
          body: onBodyWrapper(context, _buildBody(context)),
          appBar: enableAppBar ? buildAppBar(context) : null,
          bottomNavigationBar: enableBottomNavigationBar && !_useRail(context)
              ? buildBottomNavigationBar(context)
              : null,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final content = buildContent(context) ?? const SizedBox.shrink();
    return CcFadePageWrapper(child: content);
  }
}
