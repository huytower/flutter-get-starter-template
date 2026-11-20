import 'package:auto_route/auto_route.dart';
import 'package:domain_features/core/navigation/coordinator/comment_coordinator.dart';
import 'package:domain_features/core/navigation/domain_router.gr.dart';
import 'package:domain_features/features/comment/domain/entities/comment_entity.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CommentCoordinator)
class CommentCoordinatorImpl implements CommentCoordinator {
  @override
  void navigateToCommentDetail(BuildContext context, CommentEntity comment) {
    context.pushRoute(CommentDetailRoute(comment: comment));
  }
}
