import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

part 'cc_indicator_controller.dart';
part 'cc_refresh_indicator_logic.dart';
part 'cc_refresh_indicator_notifications.dart';

typedef IndicatorBuilder =
    Widget Function(
      BuildContext context,
      Widget child,
      CcIndicatorController controller,
    );

typedef OnStateChanged = void Function(IndicatorStateChange change);

extension on IndicatorTrigger {
  IndicatorEdge? get derivedEdge {
    switch (this) {
      case IndicatorTrigger.leadingEdge:
        return IndicatorEdge.leading;
      case IndicatorTrigger.trailingEdge:
        return IndicatorEdge.trailing;

      /// In this case, the side is determined by the direction of the user's
      /// first scrolling gesture, not the trigger itself.
      case IndicatorTrigger.bothEdges:
        return null;
    }
  }
}

class CcCustomRefreshIndicator extends StatefulWidget {
  /// The value from which [IndicatorController] is considered to be armed.
  static const armedFromValue = 1.0;

  /// The default distance the user must over-scroll for the indicator
  /// to be armed, as a percentage of the scrollable's container extent.
  ///
  /// This value matches the extent to armed of built-in [RefreshIndicator] ui.
  static const defaultContainerExtentPercentageToArmed = 0.25 * (1 / 1.5);

  /// Duration of hiding the indicator when dragging was stopped before
  /// the indicator was armed (the *onRefresh* callback was not called).
  ///
  /// The default is 300 milliseconds.
  final Duration indicatorCancelDuration;

  /// The time of settling the pointer on the target location after releasing
  /// the pointer in the armed state.
  ///
  /// During this process, the value of the indicator decreases from its current value,
  /// which can be greater than or equal to 1.0 but less or equal to 1.5,
  /// to a target value of `1.0`.
  /// During this process, the state is set to [IndicatorState.loading].
  ///
  /// The default is 150 milliseconds.
  final Duration indicatorSettleDuration;

  /// Duration of hiding the pointer after the [onRefresh] function completes.
  ///
  /// During this time, the value of the controller decreases from `1.0` to `0.0`
  /// with a state set to [IndicatorState.finalizing].
  ///
  /// The default is 100 milliseconds.
  final Duration indicatorFinalizeDuration;

  /// Duration for which the indicator remains at value of *1.0* and
  /// [IndicatorState.complete] state after the [onRefresh] function completes.
  final Duration? completeStateDuration;

  /// Determines whether the received [ScrollNotification] should
  /// be handled by this ui.
  ///
  /// By default, it only accepts *0* depth level notifications. This can be helpful
  /// for more complex layouts with nested scrollviews.
  final ScrollNotificationPredicate notificationPredicate;

  /// Whether to display leading scroll indicator
  final bool leadingScrollIndicatorVisible;

  /// Whether to display trailing scroll indicator
  final bool trailingScrollIndicatorVisible;

  /// The distance in number of pixels that the user should drag to arm the indicator.
  /// The armed indicator will trigger the [onRefresh] function when the gesture is completed.
  ///
  /// If not specified, [containerExtentPercentageToArmed] will be used instead.
  final double? offsetToArmed;

  /// The distance the user must scroll for the indicator to be armed,
  /// as a percentage of the scrollable's container extent.
  ///
  /// If the [offsetToArmed] argument is specified, it will be used instead,
  /// and this value will not take effect.
  ///
  /// The default value equals `0.1(6)`.
  final double containerExtentPercentageToArmed;

  /// Part of ui tree that contains scrollable ui (like ListView).
  final Widget child;

  /// Function that builds the custom refresh indicator.
  final IndicatorBuilder builder;

  /// A function that is called when the user drags the refresh indicator
  /// far enough to trigger a "pull to refresh" action.
  final AsyncCallback onRefresh;
  final AsyncCallback? onCancel;

  /// Called on every indicator state change.
  final OnStateChanged? onStateChanged;

  /// The indicator controller stores all the data related
  /// to the refresh indicator ui.
  /// It extends the [ChangeNotifier] class.
  ///
  /// TIP:
  /// Consider using it in combination with [AnimationBuilder] as animation argument
  ///
  /// The indicator controller will be passed as the third argument to the [builder] method.
  ///
  /// To better understand this data, look at example app.
  final CcIndicatorController? controller;

  /// {@macro custom_refresh_indicator.indicator_trigger}
  ///
  /// By default, the "startEdge" of the scrollable is used.
  final IndicatorTrigger trigger;

  /// Configures how [CustomRefreshIndicator] can be triggered.
  ///
  /// Works in the same way as the triggerMode of the built-in
  /// [RefreshIndicator] ui.
  ///
  /// Defaults to [IndicatorTriggerMode.onEdge].
  final IndicatorTriggerMode triggerMode;

  /// When set to true, the [builder] function will be called whenever the controller changes.
  /// It is set to `true` by default.
  ///
  /// This can be useful for optimizing performance in complex widgets.
  /// When setting this to false, you can manage which part of the ui you want to rebuild,
  /// such as using the [AnimationBuilder] ui in conjunction with [IndicatorController].
  final bool autoRebuild;

  final Axis scrollDirection;

  const CcCustomRefreshIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
    required this.builder,
    this.controller,
    this.trigger = IndicatorTrigger.leadingEdge,
    this.triggerMode = IndicatorTriggerMode.onEdge,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.autoRebuild = true,
    this.offsetToArmed,
    this.onStateChanged,
    double? containerExtentPercentageToArmed,
    this.indicatorCancelDuration = const Duration(milliseconds: 300),
    this.indicatorSettleDuration = const Duration(milliseconds: 150),
    this.indicatorFinalizeDuration = const Duration(milliseconds: 100),
    this.completeStateDuration,
    this.leadingScrollIndicatorVisible = false,
    this.trailingScrollIndicatorVisible = true,
    this.onCancel,
    this.scrollDirection = Axis.vertical,
  }) : assert(
         containerExtentPercentageToArmed == null || offsetToArmed == null,
         'Providing `extentPercentageToArmed` argument take no effect when `offsetToArmed` is provided. '
         'Remove redundant argument.',
       ),
       // set the default extent percentage value if not provided
       containerExtentPercentageToArmed =
           containerExtentPercentageToArmed ??
           defaultContainerExtentPercentageToArmed,
       super(key: key);

  @override
  CcCustomRefreshIndicatorState createState() =>
      CcCustomRefreshIndicatorState();
}

class CcCustomRefreshIndicatorState extends State<CcCustomRefreshIndicator>
    with
        TickerProviderStateMixin,
        CcCustomRefreshIndicatorLogic,
        CcCustomRefreshIndicatorNotificationHandler {}
