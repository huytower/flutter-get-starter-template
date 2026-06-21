part of 'cc_refresh_indicator.dart';

mixin CcCustomRefreshIndicatorLogic
    on State<CcCustomRefreshIndicator>, TickerProvider {
  bool _isStopingDrag = false;
  double _dragOffset = 0;
  late AnimationController _animationController;
  late bool _controllerProvided;
  late CcIndicatorController _customRefreshIndicatorController;

  CcIndicatorController get controller => _customRefreshIndicatorController;

  static const double _kPositionLimit = 1.5;
  static const double _kInitialValue = 0.0;

  @override
  void initState() {
    _dragOffset = 0;
    _controllerProvided = widget.controller != null;
    _customRefreshIndicatorController =
        widget.controller ?? CcIndicatorController._();

    _animationController = AnimationController(
      vsync: this,
      upperBound: _kPositionLimit,
      lowerBound: _kInitialValue,
      value: _kInitialValue,
    )..addListener(_updateCustomRefreshIndicatorValue);

    super.initState();
  }

  void setIndicatorState(IndicatorState newState) {
    final onStateChanged = widget.onStateChanged;
    if (onStateChanged != null && controller.state != newState) {
      onStateChanged(IndicatorStateChange(controller.state, newState));
    }
    controller.setIndicatorState(newState);
  }

  void _updateCustomRefreshIndicatorValue() =>
      _customRefreshIndicatorController.setValue(_animationController.value);

  Future<void> show({
    Duration draggingDuration = const Duration(milliseconds: 300),
    Curve draggingCurve = Curves.linear,
  }) async {
    if (!controller.state.isIdle) {
      throw StateError(
        "Cannot show indicator. "
        "Controller must be in the idle state. "
        "Current state: ${controller.state.name}.",
      );
    }
    setIndicatorState(IndicatorState.dragging);
    await _animationController.animateTo(
      1.0,
      duration: draggingDuration,
      curve: draggingCurve,
    );
    setIndicatorState(IndicatorState.armed);
    setIndicatorState(IndicatorState.settling);
    setIndicatorState(IndicatorState.loading);
  }

  Future<void> refresh({
    Duration draggingDuration = const Duration(milliseconds: 300),
    Curve draggingCurve = Curves.linear,
  }) async {
    if (!controller.state.isIdle) {
      throw StateError(
        "Cannot refresh. "
        "Controller must be in the idle state. "
        "Current state: ${controller.state.name}.",
      );
    }

    await show(
      draggingDuration: draggingDuration,
      draggingCurve: draggingCurve,
    );
    try {
      await widget.onRefresh();
    } finally {
      if (controller.state.isLoading) {
        await hide();
      }
    }
  }

  Future<void> hide() {
    if (!controller.state.isLoading) {
      throw StateError(
        'Controller must be in the loading state. '
        'Current state: ${controller.state}.',
      );
    }
    return _hideAfterRefresh();
  }

  void _calculateDragOffset(double containerExtent) {
    if (controller.state.isCanceling ||
        controller.state.isFinalizing ||
        controller.state.isLoading)
      return;

    final offsetToArmed = widget.offsetToArmed;
    final newValue = offsetToArmed != null
        ? _dragOffset / offsetToArmed
        : _dragOffset /
              (containerExtent * widget.containerExtentPercentageToArmed);

    if (newValue > 0.0 &&
        newValue < CcCustomRefreshIndicator.armedFromValue &&
        !controller.state.isDragging) {
      setIndicatorState(IndicatorState.dragging);
    } else if (newValue >= CcCustomRefreshIndicator.armedFromValue &&
        !controller.state.isArmed) {
      setIndicatorState(IndicatorState.armed);
    }

    _animationController.value = newValue.clamp(0.0, _kPositionLimit);
  }

  void _start() async {
    try {
      _dragOffset = 0;
      setIndicatorState(IndicatorState.settling);

      await _animationController.animateTo(
        1.0,
        duration: widget.indicatorSettleDuration,
      );
      setIndicatorState(IndicatorState.loading);
      await widget.onRefresh();
    } finally {
      await _hideAfterRefresh();
    }
  }

  Future<void> _hideAfterRefresh() async {
    if (!controller.state.isLoading) return;
    if (!mounted) return;

    final completeStateDuration = widget.completeStateDuration;
    if (completeStateDuration != null) {
      setIndicatorState(IndicatorState.complete);
      await Future.delayed(completeStateDuration);
    }

    if (!mounted) return;
    setIndicatorState(IndicatorState.finalizing);
    await _animationController.animateTo(
      0.0,
      duration: widget.indicatorFinalizeDuration,
    );

    if (!mounted) return;
    controller.setIndicatorEdge(null);
    setIndicatorState(IndicatorState.idle);
  }

  Future<void> _hide() async {
    setIndicatorState(IndicatorState.canceling);
    _dragOffset = 0;
    await _animationController.animateTo(
      0.0,
      duration: widget.indicatorCancelDuration,
      curve: Curves.ease,
    );

    if (!mounted) return;
    controller.setIndicatorEdge(null);
    setIndicatorState(IndicatorState.idle);
  }

  Future<void> _hideToCancel() async {
    setIndicatorState(IndicatorState.canceling);
    _dragOffset = 0;
    await _animationController.animateTo(
      0.0,
      duration: widget.indicatorCancelDuration,
      curve: Curves.ease,
    );
    if (!mounted) return;
    controller.setIndicatorEdge(null);
    setIndicatorState(IndicatorState.idle);
  }

  bool canHandleNotifications(CcIndicatorController controller) =>
      controller.state.isDragging || controller.state.isArmed;

  @override
  Widget build(BuildContext context) {
    // This build method is overridden in CcCustomRefreshIndicatorNotificationHandler
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (!_controllerProvided) {
      _customRefreshIndicatorController.dispose();
    }
    super.dispose();
  }
}
