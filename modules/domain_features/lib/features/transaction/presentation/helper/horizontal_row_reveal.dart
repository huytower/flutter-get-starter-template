import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Base width of an asset card in a horizontal asset row, and the gap between
/// two cards (those rows separate items with [CcSpaceMD], also 12pt).
const double assetCardWidth = 68;
const double assetCardGap = 12;

/// Centers the card at [index] in a horizontal card row by animating
/// [scrollController].
///
/// A horizontal card row is lazily built, so an off-screen card has no
/// [BuildContext] to `ensureVisible` — and `ensureVisible` would also scroll
/// the form's vertical list. Cards have a fixed width and a fixed gap, so the
/// offset is exact and can be applied before the card is even built. When the
/// row's scroll controller is not attached yet (the selection changed on the
/// frame the row mounted), retry for a few frames.
void revealRowCard({
  required ScrollController scrollController,
  required int index,
  required double itemWidth,
  required double itemGap,
  required double leadingPadding,
  String tag = 'RowReveal',
  int attemptsLeft = 4,
}) {
  if (index < 0) return;

  final context = Get.context;
  if (context == null) return;

  if (!scrollController.hasClients) {
    if (attemptsLeft > 0) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => revealRowCard(
          scrollController: scrollController,
          index: index,
          itemWidth: itemWidth,
          itemGap: itemGap,
          leadingPadding: leadingPadding,
          tag: tag,
          attemptsLeft: attemptsLeft - 1,
        ),
      );
    } else {
      'revealRowCard | row not attached for index=$index'.Log(tag);
    }
    return;
  }

  final width = context.respDim(itemWidth);
  final extent = width + context.respDim(itemGap);
  final leading = context.respPadding(leadingPadding);
  final position = scrollController.position;
  final target =
      (leading + index * extent - (position.viewportDimension - width) / 2)
          .clamp(0.0, position.maxScrollExtent);

  'revealRowCard | index=$index target=$target '
          'viewport=${position.viewportDimension} '
          'max=${position.maxScrollExtent}'
      .Log(tag);

  scrollController.animateTo(
    target,
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeOutCubic,
  );
}
