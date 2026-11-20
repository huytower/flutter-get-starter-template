import 'package:flutter/widgets.dart';

import '../../../features/comment/domain/entities/comment_entity.dart';

/// Navigation out of the comment feature. Implemented in `modules/bridge`
/// (`CommentCoordinatorImpl`).
abstract interface class CommentCoordinator {
  /// Opens the detail page of [comment].
  void navigateToCommentDetail(BuildContext context, CommentEntity comment);
}
