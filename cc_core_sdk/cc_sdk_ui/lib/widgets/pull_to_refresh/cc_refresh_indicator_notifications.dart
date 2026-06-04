part of 'cc_refresh_indicator.dart';

mixin CcCustomRefreshIndicatorNotificationHandler
    on CcCustomRefreshIndicatorLogic {
  bool _handleScrollIndicatorNotification(
    OverscrollIndicatorNotification notification,
  ) {
    if (notification.depth != 0) return false;
    if (notification.leading) {
      if (!widget.leadingScrollIndicatorVisible) {
        notification.disallowIndicator();
      }
    } else {
      if (!widget.trailingScrollIndicatorVisible) {
        notification.disallowIndicator();
      }
    }
    return true;
  }

  bool _canStartFromCurrentTrigger(
    ScrollNotification notification,
    IndicatorTrigger trigger,
  ) {
    switch (trigger) {
      case IndicatorTrigger.leadingEdge:
        return notification.metrics.extentBefore == 0;
      case IndicatorTrigger.trailingEdge:
        return notification.metrics.extentAfter == 0;
      case IndicatorTrigger.bothEdges:
        return notification.metrics.extentBefore == 0 ||
            notification.metrics.extentAfter == 0;
    }
  }

  bool _checkCanStart(ScrollNotification notification) {
    final isValidMode =
        (notification is ScrollStartNotification &&
            notification.dragDetails != null) ||
        (notification is ScrollUpdateNotification &&
            notification.dragDetails != null &&
            widget.triggerMode == IndicatorTriggerMode.anywhere);

    final canStart =
        isValidMode &&
        controller.isRefreshEnabled &&
        controller.state.isIdle &&
        _canStartFromCurrentTrigger(notification, widget.trigger);

    if (canStart) {
      controller
        ..setAxisDirection(notification.metrics.axisDirection)
        ..setIndicatorEdge(widget.trigger.derivedEdge);
      setIndicatorState(IndicatorState.dragging);
    }

    return canStart;
  }

  bool _checkCanHide(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final dy = notification.dragDetails?.delta.dy;
      if ((dy ?? 0) < 0 && controller.state.isLoading) {
        _hideToCancel();
        if (widget.onCancel != null) {
          widget.onCancel!();
        }
      }
    }
    return true;
  }

  bool _handleScrollUpdateNotification(ScrollUpdateNotification notification) {
    if (!controller.hasEdge && notification.scrollDelta != null) {
      if (notification.metrics.extentBefore == 0 &&
          notification.scrollDelta!.isNegative) {
        controller
          ..setIndicatorEdge(IndicatorEdge.leading)
          ..setIndicatorState(IndicatorState.dragging);
      } else if (notification.metrics.extentAfter == 0 &&
          !notification.scrollDelta!.isNegative) {
        controller
          ..setIndicatorEdge(IndicatorEdge.trailing)
          ..setIndicatorState(IndicatorState.dragging);
      }
    }

    if (controller.state.isArmed && notification.dragDetails == null) {
      _start();
    } else if (controller.state.isDragging || controller.state.isArmed) {
      switch (controller.edge) {
        case IndicatorEdge.leading:
          if (notification.metrics.extentBefore > 0.0) {
            // no-op
          } else {
            _dragOffset -= notification.scrollDelta!;
            _calculateDragOffset(notification.metrics.viewportDimension);
          }
          break;
        case IndicatorEdge.trailing:
          if (notification.metrics.extentAfter > 0.0) {
            _hide();
          } else {
            _dragOffset += notification.scrollDelta!;
            _calculateDragOffset(notification.metrics.viewportDimension);
          }
          break;
        case null:
          _hide();
          break;
      }
    }

    return false;
  }

  bool _handleOverscrollNotification(OverscrollNotification notification) {
    if (!controller.hasEdge) {
      controller.setIndicatorEdge(
        notification.overscroll.isNegative
            ? IndicatorEdge.leading
            : IndicatorEdge.trailing,
      );
    }

    if (controller.edge!.isLeading) {
      _dragOffset -= notification.overscroll;
    } else {
      _dragOffset += notification.overscroll;
    }
    _calculateDragOffset(notification.metrics.viewportDimension);
    return false;
  }

  bool _handleScrollEndNotification(ScrollEndNotification notification) {
    if (controller.state.isArmed) {
      _start();
    } else {
      _hide();
    }
    return false;
  }

  bool _handleUserScrollNotification(UserScrollNotification notification) {
    controller.setScrollingDirection(notification.direction);
    return false;
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != widget.scrollDirection) {
      return false;
    }
    if (!widget.notificationPredicate(notification)) return false;
    if (_isStopingDrag) {
      controller._shouldStopDrag = false;
      return false;
    } else if (controller._shouldStopDrag) {
      controller._shouldStopDrag = false;
      _isStopingDrag = true;

      _hide().whenComplete(() {
        _isStopingDrag = false;
      });
      return false;
    }

    if (controller.state.isIdle) {
      _checkCanStart(notification);
      return false;
    }

    if (canHandleNotifications(controller)) {
      if (notification is ScrollUpdateNotification) {
        return _handleScrollUpdateNotification(notification);
      } else if (notification is OverscrollNotification) {
        return _handleOverscrollNotification(notification);
      } else if (notification is ScrollEndNotification) {
        return _handleScrollEndNotification(notification);
      } else if (notification is UserScrollNotification) {
        return _handleUserScrollNotification(notification);
      }
    } else {
      _checkCanHide(notification);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final child = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleScrollIndicatorNotification,
        child: widget.child,
      ),
    );

    final builder = widget.builder;

    if (widget.autoRebuild) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) => builder(context, child, controller),
      );
    }
    return builder(context, child, controller);
  }
}
