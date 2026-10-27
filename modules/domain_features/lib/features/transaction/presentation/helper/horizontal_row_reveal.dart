import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;

/// Base width of an asset card in a horizontal asset row, and the gap between
/// two cards (those rows separate items with [CcSpaceMD], also 12pt).
const double assetCardWidth = 68;
const double assetCardGap = 12;

/// Centers the card at [index] in a horizontal card row by animating
/// [scrollController].
///
/// Uses a two-phase approach:
/// 1. If [itemKey] has an active [BuildContext], uses [Scrollable.ensureVisible]
///    for exact centering.
/// 2. Otherwise calculates target offset, animates [scrollController] once,
///    and refines with [Scrollable.ensureVisible] after the animation finishes.
void revealRowCard({
  required ScrollController scrollController,
  required int index,
  required double itemWidth,
  required double itemGap,
  required double leadingPadding,
  GlobalKey? itemKey,
  BuildContext? context,
  String tag = 'RowReveal',
  int attemptsLeft = 4,
}) {
  if (index < 0) return;

  '[AutoScroll] 🔍 revealRowCard requested | index=$index | tag=$tag | hasKeyContext=${itemKey?.currentContext != null} | attemptsLeft=$attemptsLeft'
      .Log(tag);

  // Approach 1: Direct GlobalKey ensureVisible if the widget is already rendered
  if (itemKey?.currentContext != null) {
    '[AutoScroll] ✨ Using Scrollable.ensureVisible via GlobalKey for index=$index'
        .Log(tag);
    Scrollable.ensureVisible(
      itemKey!.currentContext!,
      alignment: 0.5,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
    return;
  }

  if (!scrollController.hasClients) {
    if (attemptsLeft > 0) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => revealRowCard(
          scrollController: scrollController,
          index: index,
          itemWidth: itemWidth,
          itemGap: itemGap,
          leadingPadding: leadingPadding,
          itemKey: itemKey,
          context: context,
          tag: tag,
          attemptsLeft: attemptsLeft - 1,
        ),
      );
    } else {
      '[AutoScroll] ❌ revealRowCard | row not attached for index=$index'.Log(
        tag,
      );
    }
    return;
  }

  final position = scrollController.position;
  if (position.viewportDimension == 0.0) {
    if (attemptsLeft > 0) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => revealRowCard(
          scrollController: scrollController,
          index: index,
          itemWidth: itemWidth,
          itemGap: itemGap,
          leadingPadding: leadingPadding,
          itemKey: itemKey,
          context: context,
          tag: tag,
          attemptsLeft: attemptsLeft - 1,
        ),
      );
    }
    return;
  }

  final effectiveContext = context ??
      itemKey?.currentContext ??
      (scrollController.hasClients
          ? scrollController.position.context.notificationContext
          : null) ??
      Get.context;

  final width = effectiveContext != null
      ? effectiveContext.respDim(itemWidth)
      : itemWidth;
  final extent = width +
      (effectiveContext != null
          ? effectiveContext.respDim(itemGap)
          : itemGap);
  final leading = effectiveContext != null
      ? effectiveContext.respPadding(leadingPadding)
      : leadingPadding;

  // Approach 2: Calculated offset for off-screen cards
  final rawTarget =
      leading + index * extent - (position.viewportDimension - width) / 2;
  final target = rawTarget.clamp(0.0, double.infinity);

  '[AutoScroll] 🚀 Animating scrollController to target=$target | index=$index | viewport=${position.viewportDimension} | max=${position.maxScrollExtent}'
      .Log(tag);

  if (scrollController.hasClients) {
    scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );

    // Single follow-up check after animation completes to refine alignment with ensureVisible
    if (itemKey != null) {
      Future.delayed(const Duration(milliseconds: 450), () {
        if (itemKey.currentContext != null) {
          '[AutoScroll] 🎯 Post-scroll alignment via Scrollable.ensureVisible for index=$index'
              .Log(tag);
          Scrollable.ensureVisible(
            itemKey.currentContext!,
            alignment: 0.5,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
          );
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (itemKey.currentContext != null) {
              '[AutoScroll] 🎯 Post-scroll deferred alignment via Scrollable.ensureVisible for index=$index'
                  .Log(tag);
              Scrollable.ensureVisible(
                itemKey.currentContext!,
                alignment: 0.5,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
              );
            }
          });
        }
      });
    }
  }
}

