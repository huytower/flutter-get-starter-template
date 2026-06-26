import 'package:auto_route/auto_route.dart';
import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:domain_features/export_domain_features.dart';

import '../config/auto_route/app_router.gr.dart';

@LazySingleton(as: CommentCoordinator)
class CommentCoordinatorImpl implements CommentCoordinator {
  @override
  void navigateToCommentDetail(BuildContext context, dynamic comment) {
    // We assume the caller passes the correct entity type
    context.pushRoute(CommentDetailRoute(comment: comment));
  }
}
