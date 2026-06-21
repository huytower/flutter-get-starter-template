import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';

import 'cc_load_more_item.dart';

/// Mixin providing a reusable load-more wrapper.
///
/// The mixin is intentionally focused on construction and configuration.
/// The indicator presentation is extracted to [CcLoadMoreItem].
mixin CcLoadMoreMixin {
  Widget buildLoadMore({
    required Future<bool> Function() onLoadMore,
    required Widget child,
  }) {
    LoadMoreDelegate.buildWidget = () => const CcLoadMoreItem();

    return LoadMore(
      delegate: LoadMoreDelegate.buildWidget(),
      textBuilder: DefaultLoadMoreTextBuilder.english,
      onLoadMore: onLoadMore,
      child: child,
    );
  }
}
