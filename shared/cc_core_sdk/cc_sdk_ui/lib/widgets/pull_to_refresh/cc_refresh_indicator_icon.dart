import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

import 'cc_refresh_indicator.dart';

class CcRefreshIndicatorIcon extends StatefulWidget {
  final CcIndicatorController controller;
  final Widget child;
  final Widget icLoadingWidget;
  final Widget? icCompleteWidget;
  final double imageSize;
  final double indicatorSize;

  const CcRefreshIndicatorIcon({
    Key? key,
    required this.child,
    required this.controller,
    required this.icLoadingWidget,
    required this.imageSize,
    required this.indicatorSize,
    this.icCompleteWidget,
  }) : super(key: key);

  @override
  _CcRefreshIndicatorIconState createState() => _CcRefreshIndicatorIconState();
}

class _CcRefreshIndicatorIconState extends State<CcRefreshIndicatorIcon> {
  IndicatorState? currentState = IndicatorState.idle;
  bool _renderCompleteState = false;

  @override
  void initState() {
    super.initState();

    // 'initState() :'.Log();

    widget.controller.addListener(initListenerIndicator);
  }

  void initListenerIndicator() {
    if (didChange(
      to: IndicatorState.complete,
      newState: widget.controller.state,
    )) {
      setState(() {
        _renderCompleteState = true;
      });

      /// set [_renderCompleteState] to false when controller.state become idle
    } else {
      if (_renderCompleteState) {
        setState(() {
          _renderCompleteState = false;
        });
      }
    }
    if (currentState != widget.controller.state) {
      setState(() {
        currentState = widget.controller.state;
      });
    }
  }

  /// - When [from] and [to] are provided - returns `true` when state did change [from] to [to].
  /// - When only [from] is provided - returns `true` when state did change from [from].
  /// - When only [to] is provided - returns `true` when state did change to [to].
  /// - When [from] and [to] equals `null` - returns `true` for any state change.
  bool didChange({
    IndicatorState? from,
    IndicatorState? to,
    required IndicatorState newState,
  }) {
    final stateChanged = currentState != newState;
    if (to == null && from != null) {
      return currentState == from && stateChanged;
    }
    if (to != null && from == null) {
      return newState == to && stateChanged;
    }
    if (to == null && from == null) {
      return stateChanged;
    }
    return currentState == from && newState == to;
  }

  Widget _buildAnimComplete(CcIndicatorController controller) {
    var dy = -(controller.value.clamp(1.0, 1.5) - 1.0) * 20 + 10;
    if (widget.controller.value * widget.indicatorSize > widget.imageSize / 3) {
      return Transform.translate(
        offset: Offset(0, dy),
        child: OverflowBox(
          maxHeight: widget.imageSize,
          minHeight: widget.imageSize,
          child: widget.icCompleteWidget ?? widget.icLoadingWidget,
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildAnimLoading(CcIndicatorController controller) {
    var dy = -(controller.value.clamp(1.0, 1.5) - 1.0) * 20 + 10;
    if (widget.controller.value * widget.indicatorSize > widget.imageSize / 3) {
      return Transform.translate(
        offset: Offset(0, dy),
        child: OverflowBox(
          maxHeight: widget.imageSize,
          minHeight: widget.imageSize,
          child: widget.icLoadingWidget,
        ),
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        buildAnimated(),
        currentState != IndicatorState.idle &&
                currentState != IndicatorState.complete &&
                currentState != IndicatorState.finalizing
            ? buildIcLoading()
            : _renderCompleteState
            ? buildIcComplete()
            : const SizedBox(),
      ],
    );
  }

  AnimatedBuilder buildAnimated() {
    return AnimatedBuilder(
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, widget.controller.value * widget.indicatorSize),
          child: widget.child,
        );
      },
      animation: widget.controller,
    );
  }

  AnimatedBuilder buildIcComplete() {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: widget.controller.value * widget.indicatorSize,
              child: _buildAnimComplete(widget.controller),
            ),
          ],
        );
      },
    );
  }

  AnimatedBuilder buildIcLoading() {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: widget.controller.value * widget.indicatorSize,
              child: _buildAnimLoading(widget.controller),
            ),
          ],
        );
      },
    );
  }
}
